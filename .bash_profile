echo "Loading file: $(basename \"${BASH_SOURCE[0]}\")"

for tool in go groovy node yarn mvn yq jq docker-compose subfinder \
            kubent kube-linter kube-popeye kubespy k3d k9s kube-capacity \
            kubectl kubectx kubens kubetail kustomize tofu terraform \
            terragrunt terrascan helm helmify helmfile rtfmt tfsec pike helm-unittest \
            okd upx ripgrep oras k6; do
  PATH="${HOME}/binaries/${tool}/latest/bin:${PATH}"
done

PATH="/opt/homebrew/bin:${PATH}"
PATH="/opt/homebrew/opt/openjdk@11/bin:${PATH}"

PATH="${HOME}/.yarn/bin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"
PATH="${HOME}/.pyenv/shims:${PATH}"

export PATH

MAKE_CORES="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || sysctl hw.ncpu | grep -oE '[0-9]+')"
MAKEFLAGS="-j$((MAKE_CORES + 1)) -l${MAKE_CORES}"

export MAKEFLAGS

if [[ $- == *i* ]]; then
  # Ensure prompt update function is defined before PS1/PROMPT_COMMAND from .bashrc
  if [ -f ${HOME}/.bash_functions ]; then
    . "${HOME}/.bash_functions"
  fi

  if [ -f ${HOME}/.bashrc ]; then
    . "${HOME}/.bashrc"
  fi

  if [ -f ${HOME}/.bash_aliases ]; then
    . "${HOME}/.bash_aliases"
  fi

  if [ -f ${HOME}/.bash_completion ]; then
    . "${HOME}/.bash_completion"
  fi
fi


if [ -f ${HOME}/.bash_adhoc_functions ]; then
  . "${HOME}/.bash_adhoc_functions"
fi

if [ -f ${HOME}/.bash_adhoc_aliases ]; then
  . "${HOME}/.bash_adhoc_aliases"
fi

if [[ $- == *i* ]] && command -v sw_vers >/dev/null 2>&1; then
  if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  fi
fi
