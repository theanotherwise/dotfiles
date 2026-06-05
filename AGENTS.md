# Dotfiles Project Instructions

## Purpose

This project contains personal shell and tool configuration intended to be checked out directly into a user's home directory. Keep changes small and focused on the specific shell, Git, editor, or helper behavior being updated.

## Structure

- [`.bash_profile`](./.bash_profile) prepares `PATH`, exports shell defaults, and loads [`.bashrc`](./.bashrc).
- [`.README.md`](./.README.md) is only for repository initialization instructions.
- [`.bashrc`](./.bashrc) loads dotfiles startup files and sets Bash prompt/history/editor defaults.
- [`.bash_hooks`](./.bash_hooks) provides Bash-specific runtime hooks such as `preexec`/`precmd` compatibility for tools that need command lifecycle events.
- [`.dotfiles_init`](./.dotfiles_init) runs repository-owned tool initialization helpers after functions, completions, and aliases are loaded.
- [`.dotfiles_aliases`](./.dotfiles_aliases) contains aliases only; non-trivial shell logic belongs in [`.dotfiles_functions`](./.dotfiles_functions).
- [`.dotfiles_functions`](./.dotfiles_functions) contains reusable shell helper functions, including helpers that back aliases. Repository-owned shell function names must use the `sc_helper_` prefix, with public command names exposed through aliases in [`.dotfiles_aliases`](./.dotfiles_aliases).
- [`.dotfiles_completion`](./.dotfiles_completion) loads Bash completions and completion cache helpers.
- [`.gitconfig`](./.gitconfig) includes the local, untracked `~/.gitconfig.identity` file used for the active Git identity.
- [`.dotfiles`](./.dotfiles) delegates binary setup to [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py), which prints structured setup logs and installs pending tools concurrently by package while keeping each package's versions sequential.
- [`pod.yaml`](./pod.yaml) and [`init.yaml`](./init.yaml) are local Kubernetes demo manifests used to exercise Pod/container error inspection helpers.

## Placement Rules

- [`.bash_profile`](./.bash_profile) should stay limited to login-shell environment setup: `PATH`, exported build/runtime defaults, and loading [`.bashrc`](./.bashrc). Do not put aliases, reusable functions, completions, prompt logic, or tool-specific initialization blocks here.
- [`.README.md`](./.README.md) should stay limited to initializing this repository in a home directory. Do not put shell file role descriptions, Git identity usage, AI/editor policies, operational rules, or other project documentation here; keep those details in this [AGENTS.md](./AGENTS.md).
- [`.bashrc`](./.bashrc) should stay thin. It may guard shell mode, source startup files, and set prompt/history/editor defaults. Do not define functions, aliases, completion handlers, call tool-specific helpers directly, or place long inline tool setup blocks here.
- [`.bash_hooks`](./.bash_hooks) is for Bash-only command lifecycle glue such as `DEBUG` trap and `PROMPT_COMMAND` wiring. Keep it idempotent, interactive-shell-only, and limited to hook dispatch; public helper functions still belong in [`.dotfiles_functions`](./.dotfiles_functions).
- [`.dotfiles_init`](./.dotfiles_init) is for startup-time tool initialization calls such as zoxide setup. Do not define reusable functions, aliases, or completion handlers here; put definitions in [`.dotfiles_functions`](./.dotfiles_functions), [`.dotfiles_aliases`](./.dotfiles_aliases), or [`.dotfiles_completion`](./.dotfiles_completion) as appropriate.
- [`.dotfiles_functions`](./.dotfiles_functions) is where repository-owned shell logic belongs: reusable helpers, init helpers, cleanup helpers, identity switching, prompt helper commands, and functions that back public aliases. Every repository-owned function in this file must start with `sc_helper_`. Prompt helpers must not call cluster, cloud, network, or authentication CLIs during prompt rendering; they should use local state only so shell startup cannot block on external tooling.
- [`.dotfiles_aliases`](./.dotfiles_aliases) is for public command names and simple command aliases only. Do not define functions here, and do not place complex shell logic here; expose complex behavior by aliasing to a `sc_helper_` function from [`.dotfiles_functions`](./.dotfiles_functions).
- [`.dotfiles_completion`](./.dotfiles_completion) and [`.dotfiles.d/completion/`](./.dotfiles.d/completion/) are for completion loading and completion handlers only. Repository-owned completion functions must also use the `sc_helper_` prefix; upstream/vendor completion files such as [`.dotfiles.d/completion/git.bash`](./.dotfiles.d/completion/git.bash) may keep their upstream function names. Completion cache generation must be asynchronous and locked so opening many shells cannot start the same completion generator many times in parallel.
- [`.gitconfig`](./.gitconfig) should not store environment-specific active identities directly. Keep the tracked file generic and use helper-managed local files such as `~/.gitconfig.identity` for the active identity selected by shell aliases.
- [`.dotfiles`](./.dotfiles) and [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py) are for binary setup. Do not mix shell startup aliases/functions into the installer, and do not run the installer during verification unless explicitly requested.

## Tool Addition Workflow

When adding any new tool or binary, inspect how the tool is supposed to be installed before editing the installer config. Check the official release assets or upstream documentation for the correct archive, CPU architecture, executable name, archive layout, shell init requirements, and completion support. Add matching entries to both [`.dotfiles.d/macos.yaml`](./.dotfiles.d/macos.yaml) and [`.dotfiles.d/linux.yaml`](./.dotfiles.d/linux.yaml) when the tool should exist on both platforms; otherwise document why it is platform-specific.

The installed layout must match the repository convention: `${HOME}/binaries/<tool>/<version>/bin/<executable>` with `${HOME}/binaries/<tool>/latest` pointing at the selected version. Choose `strip` and `inBin` so the executable lands directly under `bin`; do not accept nested archive directories like `bin/<archive-name>/<executable>` unless that is intentionally wrapped by a helper. If the archive contains multiple executables, docs, licenses, plugins, or resources, verify which executable should be exposed, whether support files must remain next to it, and whether [`.bash_profile`](./.bash_profile), `sc_helper_dotversions_binary`, or a wrapper function needs special handling.

After adding the binary config, update the shell integration surface as needed: add the tool to the [`.bash_profile`](./.bash_profile) PATH loop, add or update `sc-versions`/`dotversions` metadata in [`.dotfiles_functions`](./.dotfiles_functions), keep category names in English, write a useful short description and example, and add aliases only in [`.dotfiles_aliases`](./.dotfiles_aliases). If the tool needs shell initialization, implement an idempotent `sc_helper_<tool>_init` function in [`.dotfiles_functions`](./.dotfiles_functions) and call it from [`.dotfiles_init`](./.dotfiles_init); do not place raw init blocks in [`.bashrc`](./.bashrc) or [`.bash_profile`](./.bash_profile).

Completion support must be checked for every new CLI. Inspect `--help`, `completion`, `completion bash`, `generate-completion`, `gen-completions`, `shell-completion`, or upstream docs to determine whether Bash completion exists; if it does, load it through [`.dotfiles_completion`](./.dotfiles_completion) using the existing cache helper, and wire aliases to the upstream completion function when aliases are added. If a tool has no built-in completion, state that in the change summary instead of silently skipping it.

Verification for binary changes must be read-only unless the user explicitly asks to install. At minimum, run syntax/parse checks for edited shell and YAML/Python files, inspect the diff, and check that the configured archive settings would place the executable in `latest/bin`. When the user explicitly asks to run setup or verify an installed tool, inspect the real `${HOME}/binaries/<tool>/latest/bin` layout, confirm the executable is on `PATH`, check its version command, check whether init/completion loads cleanly, and confirm `sc-versions`/`dotversions` shows the tool in the intended category.

## Execution Constraints

Use `bash` for shell checks. Do not run [`.dotfiles`](./.dotfiles) or [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py) unless explicitly requested, because they download and install local binaries. When inspecting installer behavior, use syntax checks or isolated function-level tests instead of running the real installer.

When changing shell files, prefer focused syntax checks such as `bash -n` on the edited file. Do not run commands that mutate the user's real home Git config during verification; use inspection or an isolated temporary home if behavior must be exercised.

Do not apply [`pod.yaml`](./pod.yaml) or [`init.yaml`](./init.yaml) to a Kubernetes cluster unless the user explicitly asks for that mutating action. Validation with client-side dry-run is acceptable.
