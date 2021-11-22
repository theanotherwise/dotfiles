alias ls='ls --color=auto --hide=".*"'
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rmdir="rmdir -v"

alias graph="git log --graph --abbrev-commit --decorate=full --all --color=always --date=iso"

CURSOR="$([ ${USER} == root ] && echo '#' || echo '$')"

PS1="[\[\e[31m\]\u\[\e[m\]][\l]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]${CURSOR} "
HISTSIZE="10000"
HISTFILESIZE="10000"
HISTTIMEFORMAT="%Y-%m-%d %T "
EDITOR="vim"

export PS1
export HISTSIZE
export HISTFILESIZE
export HISTTIMEFORMAT
export EDITOR
