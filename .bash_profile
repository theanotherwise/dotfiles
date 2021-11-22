if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

umask 0022

PATH="~/bin/ruby/latest/bin:$PATH"
PATH="/opt/ruby/latest/bin:$PATH"

PATH="~/bin/terraform/latest/bin:$PATH"
PATH="/opt/terraform/latest/bin:$PATH"

PATH="~/bin/helm/latest/bin:$PATH"
PATH="/opt/helm/latest/bin:$PATH"

PATH="~/bin/node/latest/bin:$PATH"
PATH="/opt/node/latest/bin:$PATH"

PATH="~/bin/yarn/latest/bin:$PATH"
PATH="/opt/yarn/latest/bin:$PATH"

export PATH
