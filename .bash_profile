if [ -f ${HOME}/.bashrc ] ; then
  . ${HOME}/.bashrc
fi

PATH="${HOME}/binaries/k3d/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubectl/latest/bin:${PATH}"
PATH="${HOME}/binaries/helm/latest/bin:${PATH}"
PATH="${HOME}/binaries/kustomize/latest/bin:${PATH}"
PATH="${HOME}/binaries/node/latest/bin:${PATH}"
PATH="${HOME}/binaries/yarn/latest/bin:${PATH}"
PATH="${HOME}/binaries/terraform/latest/bin:${PATH}"
PATH="${HOME}/binaries/python/latest/bin:${PATH}"
PATH="${HOME}/binaries/ruby/latest/bin:${PATH}"
PATH="${HOME}/binaries/upx/latest/bin:${PATH}"
PATH="${HOME}/binaries/okd/latest/bin:${PATH}"

MAKE_CORES="$(grep -c '^processor' /proc/cpuinfo)"
MAKEFLAGS="-j$((MAKE_CORES+1)) -l${MAKE_CORES}"

export PATH
export MAKEFLAGS

if command -v kubectl > /dev/null 2>&1 ; then
  . <(kubectl completion bash)
fi

if command -v oc3.11 >/dev/null 2>&1; then
  . <(oc3.11 completion bash | sed "s/_oc_/_oc_3_11_/g" | sed "s/__start_oc/__start_oc_3_11/g")
  complete -F __start_oc_3_11 oc3.11
fi

if command -v oc4.10 >/dev/null 2>&1; then
  . <(oc4.10 completion bash | sed "s/_oc_/_oc_4_10_/g" | sed "s/__start_oc/__start_oc_4_10/g")
  complete -F __start_oc_4_10 oc4.10
fi

if command -v kubectl3.11 >/dev/null 2>&1; then
  . <(kubectl3.11 completion bash | sed "s/_oc_/_kubectl_3_11_/g" | sed "s/__start_oc/__start_kubectl_3_11/g")
  complete -F __start_kubectl_3_11 kubectl3.11
fi

if command -v kubectl4.10 >/dev/null 2>&1; then
  . <(kubectl4.10 completion bash | sed "s/_oc_/_kubectl_4_10_/g" | sed "s/__start_oc/__start_kubectl_4_10/g")
  complete -F __start_kubectl_4_10 kubectl4.10
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

if [ -f ${HOME}/.dotfiles/git-completion.bash ] ; then
  . ${HOME}/.dotfiles/git-completion.bash
fi
