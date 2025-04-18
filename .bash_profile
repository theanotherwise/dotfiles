echo "Loading file: $(basename "${BASH_SOURCE[0]}")"

PATH="${HOME}/binaries/go/latest/bin:${PATH}"
PATH="${HOME}/binaries/groovy/latest/bin:${PATH}"
PATH="${HOME}/binaries/node/latest/bin:${PATH}"
PATH="${HOME}/binaries/yarn/latest/bin:${PATH}"
PATH="${HOME}/binaries/mvn/latest/bin:${PATH}"
PATH="${HOME}/binaries/yq/latest/bin:${PATH}"
PATH="${HOME}/binaries/jq/latest/bin:${PATH}"
PATH="${HOME}/binaries/docker-compose/latest/bin:${PATH}"
PATH="${HOME}/binaries/subfinder/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubent/latest/bin:${PATH}"
PATH="${HOME}/binaries/kube-linter/latest/bin:${PATH}"
PATH="${HOME}/binaries/kube-popeye/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubespy/latest/bin:${PATH}"
PATH="${HOME}/binaries/k3d/latest/bin:${PATH}"
PATH="${HOME}/binaries/k9s/latest/bin:${PATH}"
PATH="${HOME}/binaries/kube-capacity/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubectl/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubectx/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubens/latest/bin:${PATH}"
PATH="${HOME}/binaries/kubetail/latest/bin:${PATH}"
PATH="${HOME}/binaries/kustomize/latest/bin:${PATH}"
PATH="${HOME}/binaries/tofu/latest/bin:${PATH}"
PATH="${HOME}/binaries/terraform/latest/bin:${PATH}"
PATH="${HOME}/binaries/terragrunt/latest/bin:${PATH}"
PATH="${HOME}/binaries/terrascan/latest/bin:${PATH}"
PATH="${HOME}/binaries/helm/latest/bin:${PATH}"
PATH="${HOME}/binaries/helmify/latest/bin:${PATH}"
PATH="${HOME}/binaries/helmfile/latest/bin:${PATH}"
PATH="${HOME}/binaries/tflint/latest/bin:${PATH}"
PATH="${HOME}/binaries/tfsec/latest/bin:${PATH}"
PATH="${HOME}/binaries/pike/latest/bin:${PATH}"
PATH="${HOME}/binaries/okd/latest/bin:${PATH}"
PATH="${HOME}/binaries/upx/latest/bin:${PATH}"
PATH="${HOME}/binaries/ripgrep/latest/bin:${PATH}"
PATH="${HOME}/binaries/oras/latest/bin:${PATH}"

PATH="/opt/homebrew/bin:${PATH}"
PATH="/opt/homebrew/opt/openjdk@11/bin:${PATH}"

PATH="${HOME}/.yarn/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"
PATH="${HOME}/.pyenv/shims:${PATH}"

export PATH

MAKE_CORES="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || sysctl hw.ncpu | grep -oE '[0-9]+')"
MAKEFLAGS="-j$((MAKE_CORES + 1)) -l${MAKE_CORES}"

export MAKEFLAGS

if [ -f ${HOME}/.bashrc ]; then
  . "${HOME}/.bashrc"
fi

if [ -f ${HOME}/.bash_functions ]; then
  . "${HOME}/.bash_functions"
fi

if [ -f ${HOME}/.bash_aliases ]; then
  . "${HOME}/.bash_aliases"
fi

#if [ -f ${HOME}/.bash_completion ]; then
#  . "${HOME}/.bash_completion"
#fi

if [ -f ${HOME}/.bash_adhoc_functions ]; then
  . "${HOME}/.bash_adhoc_functions"
fi

if [ -f ${HOME}/.bash_adhoc_aliases ]; then
  . "${HOME}/.bash_adhoc_aliases"
fi

if command -v sw_vers >/dev/null 2>&1; then
  if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  fi
fi
