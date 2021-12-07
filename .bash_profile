if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
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

if command -v kubectl > /dev/null 2>&1 ; then
  . <(kubectl completion bash)
fi

if command -v helm > /dev/null 2>&1 ; then
  . <(helm completion bash)
fi

if [ -f ~/.dotfiles/git-completion.bash ] ; then
  . ~/.dotfiles/git-completion.bash
fi
