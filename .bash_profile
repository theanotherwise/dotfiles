if [ -f ${HOME}/.bashrc ] ; then
  . ${HOME}/.bashrc
fi

PATH="/opt/ruby/latest/bin:${PATH}"                     # Ruby
PATH="${HOME}/binaries/ruby/latest/bin:${PATH}"
PATH="/opt/terraform/latest/bin:${PATH}"                # Terraform
PATH="${HOME}/binaries/terraform/latest/bin:${PATH}"
PATH="/opt/helm/latest/bin:${PATH}"                     # Helm
PATH="${HOME}/binaries/helm/latest/bin:${PATH}"
PATH="/opt/node/latest/bin:${PATH}"                     # Node
PATH="${HOME}/binaries/node/latest/bin:${PATH}"
PATH="/opt/yarn/latest/bin:${PATH}"                     # Yarn
PATH="${HOME}/binaries/yarn/latest/bin:${PATH}"
PATH="/opt/kubectl/latest/bin:${PATH}"                  # Kubectl
PATH="${HOME}/binaries/kubectl/latest/bin:${PATH}"  
PATH="/opt/k3d/latest/bin:${PATH}"                      # K3d
PATH="${HOME}/binaries/k3d/latest/bin:${PATH}"
PATH="/opt/python/latest/bin:${PATH}"                   # Python
PATH="${HOME}/binaries/python/latest/bin:${PATH}"
PATH="/opt/ruby/latest/bin:${PATH}"                     # Ruby
PATH="${HOME}/binaries/ruby/latest/bin:${PATH}"

export PATH

if command -v kubectl > /dev/null 2>&1 ; then           # Kubectl Completion
  . <(kubectl completion bash)
fi

if command -v helm > /dev/null 2>&1 ; then              # Helm Completion
  . <(helm completion bash)
fi

if command -v k3d > /dev/null 2>&1 ; then               # K3d Completion
  . <(k3d  completion bash)
fi

if [ -f ${HOME}/.dotfiles/git-completion.bash ] ; then  # Git Completion
  . ${HOME}/.dotfiles/git-completion.bash
fi
