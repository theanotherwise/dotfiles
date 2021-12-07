alias ls='ls --color=auto --hide=".*"'
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rmdir="rmdir -v"
alias graph="git log --graph --abbrev-commit --decorate=full --all --color=always --date=iso --log-size --raw --stat"

branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

retval() {
  RETVAL="${?}"
  [[ "${RETVAL}" != "0" ]] && echo "[${RETVAL}]"
}

CURSOR="$([[ "${UID}" == "0" ]] && echo '#' || echo '$')"

export PS1="[\[\e[31m\]\u\[\e[m\]]\$(retval)@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]${CURSOR} \[\e[33m\]\$(branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"
