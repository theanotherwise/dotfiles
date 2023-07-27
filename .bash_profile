if [ -f ${HOME}/.bashrc ] ; then
  . ${HOME}/.bashrc
fi

PATH="${HOME}/binaries/yq/latest/bin:${PATH}"
PATH="${HOME}/binaries/jq/latest/bin:${PATH}"
PATH="${HOME}/binaries/k3d/latest/bin:${PATH}"
PATH="${HOME}/binaries/okd/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubectl/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubectx/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubens/latest/bin:${PATH}"
PATH="${HOME}/binaries/kube-capacity/latest/bin:${PATH}"
PATH="${HOME}/binaries/helm/latest/bin:${PATH}"
PATH="${HOME}/binaries/kustomize/latest/bin:${PATH}"
PATH="${HOME}/binaries/go/latest/bin:${PATH}"
PATH="${HOME}/binaries/groovy/latest/bin:${PATH}"
PATH="${HOME}/binaries/python/latest/bin:${PATH}"
PATH="${HOME}/binaries/ruby/latest/bin:${PATH}"
PATH="${HOME}/binaries/node/latest/bin:${PATH}"
PATH="${HOME}/binaries/yarn/latest/bin:${PATH}"
PATH="${HOME}/binaries/terraform/latest/bin:${PATH}"
PATH="${HOME}/binaries/terragrunt/latest/bin:${PATH}"
PATH="${HOME}/binaries/upx/latest/bin:${PATH}"

export PATH

MAKE_CORES="$(grep -c '^processor' /proc/cpuinfo)"
MAKEFLAGS="-j$((MAKE_CORES+1)) -l${MAKE_CORES}"

export MAKEFLAGS

if command -v kubectl > /dev/null 2>&1 ; then
  . <(kubectl completion bash)
fi

if command -v kustomize > /dev/null 2>&1 ; then
  . <(kustomize completion bash)
fi

if command -v helm > /dev/null 2>&1 ; then
  . <(helm completion bash)
fi

if command -v k3d > /dev/null 2>&1 ; then
  . <(k3d  completion bash)
fi

if [ -f ${HOME}/.dotfiles/git.bash ] ; then
  . ${HOME}/.dotfiles/git.bash
fi

if [ -f ${HOME}/.dotfiles/kubectx.bash ] ; then
  . ${HOME}/.dotfiles/kubectx.bash
fi

if [ -f ${HOME}/.dotfiles/kubens.bash ] ; then
  . ${HOME}/.dotfiles/kubens.bash
fi

if command -v oc3.11 > /dev/null 2>&1 ; then
  . <(oc3.11 completion bash | sed "s/_oc/_oc311/g")
fi

if command -v oc4.10 > /dev/null 2>&1 ; then
  . <(oc4.10 completion bash | sed "s/_oc/_oc410/g")
fi

if command -v oc4.11 > /dev/null 2>&1 ; then
  . <(oc4.11 completion bash | sed "s/_oc/_oc411/g")
fi

# Must be in End of Profile
if [ -f ${HOME}/.dotfiles/complete.bash ] ; then
  . ${HOME}/.dotfiles/complete.bash
fi