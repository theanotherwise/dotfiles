# if [ -f ~/.examplerc ] ; then
#   . ~/.examplerc
# fi
 
PS1="[\[\e[32m\]\u\[\e[m\]][\l]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]# "
HISTTIMEFORMAT="%Y-%m-%d %T "

alias ls='ls --color=auto --hide=".*"'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rmdir='rmdir -v'

export PS1
export HISTTIMEFORMAT
