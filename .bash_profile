if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

umask 0022

PATH=~/portable/ruby/latest/bin:$PATH
PATH=~/portable/terraform/latest/bin:$PATH
PATH=~/portable/helm/latest/bin:$PATH
PATH=~/portable/node.js/latest/bin:$PATH
PATH=~/biportablen/yarn/latest/bin:$PATH

export PATH