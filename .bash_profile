if [ -f ${HOME}/.bashrc ] ; then
  . ${HOME}/.bashrc
fi

PATH="${HOME}/binaries/ruby/latest/bin:${PATH}"
PATH="${HOME}/binaries/terraform/latest/bin:${PATH}"
PATH="${HOME}/binaries/helm/latest/bin:${PATH}"
PATH="${HOME}/binaries/node/latest/bin:${PATH}"
PATH="${HOME}/binaries/yarn/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubectl/latest/bin:${PATH}"
PATH="${HOME}/binaries/kustomize/latest/bin:${PATH}"
PATH="${HOME}/binaries/k3d/latest/bin:${PATH}"
PATH="${HOME}/binaries/python/latest/bin:${PATH}"
PATH="${HOME}/binaries/ruby/latest/bin:${PATH}"

MAKE_CORES="$(grep -c '^processor' /proc/cpuinfo)"
MAKEFLAGS="-j$((MAKE_CORES+1)) -l${MAKE_CORES}"

export PATH
export MAKEFLAGS

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
