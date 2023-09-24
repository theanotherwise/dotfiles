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

if [ -f ~/.bash_completion ] ; then
  . ~/.bash_completion
fi