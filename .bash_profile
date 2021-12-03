if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

if command -v kubectl 2>&1 > /dev/null ; then
  . <(kubectl completion bash)
fi

umask 0022

PATH="/opt/ruby/latest/bin:${PATH}"
PATH="~/binaries/ruby/latest/bin:${PATH}"

PATH="/opt/terraform/latest/bin:${PATH}"
PATH="~/binaries/terraform/latest/bin:${PATH}"

PATH="/opt/helm/latest/bin:${PATH}"
PATH="~/binaries/helm/latest/bin:${PATH}"

PATH="/opt/node/latest/bin:${PATH}"
PATH="~/binaries/node/latest/bin:${PATH}"

PATH="/opt/yarn/latest/bin:${PATH}"
PATH="~/binaries/yarn/latest/bin:${PATH}"

export PATH
