if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

umask 0022

PATH="${HOME}/bin/ruby/latest/bin:$PATH"
PATH="/opt/ruby/latest/bin:$PATH"

PATH="${HOME}/bin/terraform/latest/bin:$PATH"
PATH="/opt/terraform/latest/bin:$PATH"

PATH="${HOME}/bin/helm/latest/bin:$PATH"
PATH="/opt/helm/latest/bin:$PATH"

PATH="${HOME}/bin/node.js/latest/bin:$PATH"
PATH="/opt/node.js/latest/bin:$PATH"

PATH="${HOME}/bin/yarn/latest/bin:$PATH"
PATH="/opt/yarn/latest/bin:$PATH"

export PATH
