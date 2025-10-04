[ -n "$DOTFILES_DEBUG" ] && echo "Loading file: $(basename \"${BASH_SOURCE[0]}\")"

umask 0022

# Skip the rest for non-interactive shells
[[ $- != *i* ]] && return

export PS1="\[\e[1;34m\]${SC_PROMPT_KUBE}\[\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]${SC_PROMPT_CURSOR} \[\e[33m\]${SC_PROMPT_BRANCH}\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"

# Ensure prompt metadata is updated before each prompt without heavy work
if ! declare -F sc_prompt_update >/dev/null 2>&1; then
  sc_prompt_update() { :; }
fi
PROMPT_COMMAND="sc_prompt_update${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
