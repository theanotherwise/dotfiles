if [[ -n "${SC_BASH_SHOW_LOADING:-}" ]]; then
  echo "Loading file: $(basename "${BASH_SOURCE[0]}")"
fi

umask 0022

# Load for interactive shells and also for login non-interactive shells (e.g. `bash -lc`).
if [[ $- != *i* ]]; then
  shopt -q login_shell || return
fi

# Keep interactive non-login shells (`bash`) consistent with login shell startup.
if [ -f "${HOME}/.bash_functions" ]; then
  . "${HOME}/.bash_functions"
fi

if [ -f "${HOME}/.bash_adhoc_functions" ]; then
  . "${HOME}/.bash_adhoc_functions"
fi

if command -v sw_vers >/dev/null 2>&1 && [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
fi
if [ -f "${HOME}/.bash_completion" ]; then
  . "${HOME}/.bash_completion"
fi

if [ -f "${HOME}/.bash_aliases" ]; then
  . "${HOME}/.bash_aliases"
fi

if [ -f "${HOME}/.bash_adhoc_aliases" ]; then
  . "${HOME}/.bash_adhoc_aliases"
fi

export PS1="\[\e[1;34m\]\$(sc_helper_bashrc_kube)\[\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(sc_helper_bashrc_cursor) \[\e[33m\]\$(sc_helper_bashrc_branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"

# No header on Enter; kube context shown on the right in PS1 as before
