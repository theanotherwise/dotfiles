alias ls='ls --color=auto --hide=".*"'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rmdir='rmdir -v'

PS1='[\[\e[31m\]\u\[\e[m\]][\l]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]# '
export PS1

HISTTIMEFORMAT='%Y-%m-%d %T '
export HISTTIMEFORMAT

EDITOR='vim'
export EDITOR