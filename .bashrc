if [[ -n "${SC_BASH_SHOW_LOADING:-}" ]]; then
  echo "Loading file: $(basename "${BASH_SOURCE[0]}")"
fi

umask 0022

# Load for interactive shells and also for login non-interactive shells (e.g. `bash -lc`).
if [[ $- != *i* ]]; then
  shopt -q login_shell || return 0
fi

# Keep interactive non-login shells (`bash`) consistent with login shell startup.
if [ -f "${HOME}/.dot/functions" ]; then
  . "${HOME}/.dot/functions"
fi

if [ -f "${HOME}/.dot/adhoc_functions" ]; then
  . "${HOME}/.dot/adhoc_functions"
fi

if command -v sw_vers >/dev/null 2>&1 && [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
fi
if [ -f "${HOME}/.dot/completion" ]; then
  . "${HOME}/.dot/completion"
fi

if [ -f "${HOME}/.dot/aliases" ]; then
  . "${HOME}/.dot/aliases"
fi

if [ -f "${HOME}/.dot/adhoc_aliases" ]; then
  . "${HOME}/.dot/adhoc_aliases"
fi

if [ -f "${HOME}/.dot/init" ]; then
  . "${HOME}/.dot/init"
fi

export PS1="\[\e[1;34m\$(sc_helper_bashrc_kube)\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(sc_helper_bashrc_cursor) \[\e[33m\]\$(sc_helper_bashrc_branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
unset HISTFILE
export EDITOR="vim"
