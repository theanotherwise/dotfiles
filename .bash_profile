if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

umask 0022
 
PATH=~/portable/terraform/latest:$PATH
PATH=~/portable/ruby/latest:$PATH
PATH=~/portable/node.js/latest:$PATH
PATH=~/portable/yarn/latest:$PATH
PATH=~/portable/redis/latest:$PATH

export PATH

EDITOR=vim
export EDITOR
