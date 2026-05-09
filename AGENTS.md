# Dotfiles Project Instructions

## Purpose

This project contains personal shell and tool configuration intended to be checked out directly into a user's home directory. Keep changes small and focused on the specific shell, Git, editor, or helper behavior being updated.

## Structure

- [`.bash_profile`](./.bash_profile) prepares `PATH`, exports shell defaults, and loads [`.bashrc`](./.bashrc).
- [`.bashrc`](./.bashrc) loads shell functions, completion, aliases, prompt setup, and interactive shell defaults.
- [`.bash_aliases`](./.bash_aliases) contains aliases only; non-trivial shell logic belongs in [`.bash_functions`](./.bash_functions).
- [`.bash_functions`](./.bash_functions) contains reusable shell helper functions, including helpers that back aliases.
- [`.gitconfig`](./.gitconfig) includes the local, untracked `~/.gitconfig.identity` file used for the active Git identity.
- [`.dotfiles`](./.dotfiles) delegates binary setup to [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py).

## Execution Constraints

Use `bash` for shell checks. Do not run [`.dotfiles`](./.dotfiles) or [`.dotfiles.d/dotfiles.py`](./.dotfiles.d/dotfiles.py) unless explicitly requested, because they download and install local binaries.

When changing shell files, prefer focused syntax checks such as `bash -n` on the edited file. Do not run commands that mutate the user's real home Git config during verification; use inspection or an isolated temporary home if behavior must be exercised.
