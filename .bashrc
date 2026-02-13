if [[ -n "${SC_BASH_SHOW_LOADING:-}" ]]; then
  echo "Loading file: $(basename "${BASH_SOURCE[0]}")"
fi

umask 0022

# Skip the rest for non-interactive shells
[[ $- != *i* ]] && return

export PS1="\[\e[1;34m\]\$(sc_helper_bashrc_kube)\[\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(sc_helper_bashrc_cursor) \[\e[33m\]\$(sc_helper_bashrc_branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"

# No header on Enter; kube context shown on the right in PS1 as before
