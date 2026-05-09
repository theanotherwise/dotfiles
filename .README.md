# `.dotfiles`

## Setup

```bash
git -C "${HOME}" init
git -C "${HOME}" remote add origin https://github.com/theanotherwise/dotfiles.git
git -C "${HOME}" pull origin main
bash "${HOME}/.dotfiles"
```

## Prompts

```bash
AGENTS.md Policy

- Always read AGENTS.md at the start
- Each time, check whether AGENTS.md has changed
- If AGENTS.md has changed, read it again


Shell Execution Policy

- Never use zsh when executing any command
- Do not execute commands using bash -c "…"
- Always load the user’s .bash_profile and execute commands as a regular user would
- Do not use bash -c as a workaround
- At the beginning of each session, load .bash_profile separately without combining it with other commands
- If the user requests a reload, load it again using source
- Always use source to load .bash_profile, never use the dot (.) syntax
```
