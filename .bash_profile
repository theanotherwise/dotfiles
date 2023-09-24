if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

PATH="~/binaries/yq/latest/bin:${PATH}"
PATH="~/binaries/jq/latest/bin:${PATH}"
PATH="~/binaries/k3d/latest/bin:${PATH}"
PATH="~/binaries/okd/latest/bin:${PATH}"
PATH="~/binaries/kubectl/latest/bin:${PATH}"
PATH="~/binaries/kubectx/latest/bin:${PATH}"
PATH="~/binaries/kubens/latest/bin:${PATH}"
PATH="~/binaries/kubetail/latest/bin:${PATH}"
PATH="~/binaries/kube-capacity/latest/bin:${PATH}"
PATH="~/binaries/helm/latest/bin:${PATH}"
PATH="~/binaries/kustomize/latest/bin:${PATH}"
PATH="~/binaries/go/latest/bin:${PATH}"
PATH="~/binaries/groovy/latest/bin:${PATH}"
PATH="~/binaries/python/latest/bin:${PATH}"
PATH="~/binaries/ruby/latest/bin:${PATH}"
PATH="~/binaries/node/latest/bin:${PATH}"
PATH="~/binaries/yarn/latest/bin:${PATH}"
PATH="~/binaries/terraform/latest/bin:${PATH}"
PATH="~/binaries/terragrunt/latest/bin:${PATH}"
PATH="~/binaries/upx/latest/bin:${PATH}"
PATH="~/binaries/k9s/latest/bin:${PATH}"

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

if [ -f ~/.dotfiles/completion/git.bash ] ; then
  . ~/.dotfiles/completion/git.bash
fi

if [ -f ~/.dotfiles/completion/kubectx.bash ] ; then
  . ~/.dotfiles/completion/kubectx.bash
fi

if [ -f ~/.dotfiles/completion/kubens.bash ] ; then
  . ~/.dotfiles/completion/kubens.bash
fi

if [ -f ~/.dotfiles/completion/kubetail.bash ] ; then
  . ~/.dotfiles/completion/kubetail.bash
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
if [ -f ~/.dotfiles/completion/generic.bash ] ; then
  . ~/.dotfiles/completion/generic.bash
fi