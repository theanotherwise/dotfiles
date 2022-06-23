PATH="/opt/ruby/latest/bin:${PATH}"
PATH="/${HOME}/binaries/ruby/latest/bin:${PATH}"
PATH="/opt/terraform/latest/bin:${PATH}"
PATH="/${HOME}/binaries/terraform/latest/bin:${PATH}"
PATH="/opt/helm/latest/bin:${PATH}"
PATH="/${HOME}/binaries/helm/latest/bin:${PATH}"
PATH="/opt/node/latest/bin:${PATH}"
PATH="/${HOME}/binaries/node/latest/bin:${PATH}"
PATH="/opt/yarn/latest/bin:${PATH}"
PATH="/${HOME}/binaries/yarn/latest/bin:${PATH}"
PATH="/opt/kubectl/latest/bin:${PATH}"
PATH="/${HOME}/binaries/kubectl/latest/bin:${PATH}"
PATH="/opt/k3d/latest/bin:${PATH}"
PATH="/${HOME}/binaries/k3d/latest/bin:${PATH}"

export PATH

if command -v kubectl > /dev/null 2>&1 ; then
  . <(kubectl completion bash)
fi

if command -v helm > /dev/null 2>&1 ; then
  . <(helm completion bash)
fi

if command -v k3d > /dev/null 2>&1 ; then
  . <(k3d  completion bash)
fi

if [ -f /${HOME}/.dotfiles/git-completion.bash ] ; then
  . /${HOME}/.dotfiles/git-completion.bash
fi
