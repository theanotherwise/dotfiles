# Dotfiles Project Instructions

## Purpose

This project contains personal shell and tool configuration intended to be checked out directly into a user's home directory. Keep changes small and focused on the specific shell, Git, editor, or helper behavior being updated.

## Structure

- [`.bash_profile`](./.bash_profile) prepares `PATH`, exports shell defaults, and loads [`.bashrc`](./.bashrc).
- [`.README.md`](./.README.md) is only for repository initialization instructions.
- [`.bashrc`](./.bashrc) loads shell startup files and sets prompt/history/editor defaults.
- [`.bash_init`](./.bash_init) runs repository-owned tool initialization helpers after functions, completions, and aliases are loaded.
- [`.bash_aliases`](./.bash_aliases) contains aliases only; non-trivial shell logic belongs in [`.bash_functions`](./.bash_functions).
- [`.bash_functions`](./.bash_functions) contains reusable shell helper functions, including helpers that back aliases. Repository-owned shell function names must use the `sc_helper_` prefix, with public command names exposed through aliases in [`.bash_aliases`](./.bash_aliases).
- [`.gitconfig`](./.gitconfig) includes the local, untracked `~/.gitconfig.identity` file used for the active Git identity.
- [`.dotfiles`](./.dotfiles) delegates binary setup to [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py).

## Placement Rules

- [`.bash_profile`](./.bash_profile) should stay limited to login-shell environment setup: `PATH`, exported build/runtime defaults, and loading [`.bashrc`](./.bashrc). Do not put aliases, reusable functions, completions, prompt logic, or tool-specific initialization blocks here.
- [`.README.md`](./.README.md) should stay limited to initializing this repository in a home directory. Do not put shell file role descriptions, Git identity usage, AI/editor policies, operational rules, or other project documentation here; keep those details in this [AGENTS.md](./AGENTS.md).
- [`.bashrc`](./.bashrc) should stay thin. It may guard shell mode, source startup files, and set prompt/history/editor defaults. Do not define functions, aliases, completion handlers, call tool-specific helpers directly, or place long inline tool setup blocks here.
- [`.bash_init`](./.bash_init) is for startup-time tool initialization calls such as zoxide setup. Do not define reusable functions, aliases, or completion handlers here; put definitions in [`.bash_functions`](./.bash_functions), [`.bash_aliases`](./.bash_aliases), or [`.bash_completion`](./.bash_completion) as appropriate.
- [`.bash_functions`](./.bash_functions) is where repository-owned shell logic belongs: reusable helpers, init helpers, cleanup helpers, identity switching, prompt helper commands, and functions that back public aliases. Every repository-owned function in this file must start with `sc_helper_`.
- [`.bash_aliases`](./.bash_aliases) is for public command names and simple command aliases only. Do not define functions here, and do not place complex shell logic here; expose complex behavior by aliasing to a `sc_helper_` function from [`.bash_functions`](./.bash_functions).
- [`.bash_completion`](./.bash_completion) and [`.dotfiles.d/completion/`](./.dotfiles.d/completion/) are for completion loading and completion handlers only. Repository-owned completion functions must also use the `sc_helper_` prefix; upstream/vendor completion files such as [`.dotfiles.d/completion/git.bash`](./.dotfiles.d/completion/git.bash) may keep their upstream function names.
- [`.gitconfig`](./.gitconfig) should not store environment-specific active identities directly. Keep the tracked file generic and use helper-managed local files such as `~/.gitconfig.identity` for the active identity selected by shell aliases.
- [`.dotfiles`](./.dotfiles) and [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py) are for binary setup. Do not mix shell startup aliases/functions into the installer, and do not run the installer during verification unless explicitly requested.

## Execution Constraints

Use `bash` for shell checks. Do not run [`.dotfiles`](./.dotfiles) or [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py) unless explicitly requested, because they download and install local binaries.

When changing shell files, prefer focused syntax checks such as `bash -n` on the edited file. Do not run commands that mutate the user's real home Git config during verification; use inspection or an isolated temporary home if behavior must be exercised.
