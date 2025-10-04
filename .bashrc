echo "Loading file: $(basename \"${BASH_SOURCE[0]}\")"

umask 0022

# Skip the rest for non-interactive shells
[[ $- != *i* ]] && return

export PS1="\[$(sc_helper_bashrc_kube)\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(sc_helper_bashrc_cursor) \[\e[33m\]\$(sc_helper_bashrc_branch)\[\e[m\]"

# Keep COLUMNS/LINES in sync after window resizes
shopt -s checkwinsize
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"

# No PROMPT_COMMAND hook; prompt functions run inline on each render
