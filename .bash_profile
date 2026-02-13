if [[ -n "${SC_BASH_SHOW_LOADING:-}" ]]; then
  echo "Loading file: $(basename "${BASH_SOURCE[0]}")"
fi

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

MAKE_CORES="$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)"
[[ "${MAKE_CORES}" =~ ^[0-9]+$ ]] || MAKE_CORES=1
MAKEFLAGS="-j$((MAKE_CORES + 1)) -l${MAKE_CORES}"

export MAKEFLAGS

SC_HAS_BREW_BASH_COMPLETION=0
if [[ $- == *i* ]] && command -v sw_vers >/dev/null 2>&1 && [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  SC_HAS_BREW_BASH_COMPLETION=1
fi

if [[ $- == *i* ]]; then
  # Ensure prompt update function is defined before PS1/PROMPT_COMMAND from .bashrc
  if [ -f "${HOME}/.bash_functions" ]; then
    . "${HOME}/.bash_functions"
  fi

  if [ -f "${HOME}/.bashrc" ]; then
    . "${HOME}/.bashrc"
  fi

  if [ -f "${HOME}/.bash_aliases" ]; then
    . "${HOME}/.bash_aliases"
  fi

  if [ "${SC_HAS_BREW_BASH_COMPLETION}" -eq 0 ] && [ -f "${HOME}/.bash_completion" ]; then
    . "${HOME}/.bash_completion"
  fi
fi


if [ -f "${HOME}/.bash_adhoc_functions" ]; then
  . "${HOME}/.bash_adhoc_functions"
fi

if [ -f "${HOME}/.bash_adhoc_aliases" ]; then
  . "${HOME}/.bash_adhoc_aliases"
fi

if [[ $- == *i* ]] && [ "${SC_HAS_BREW_BASH_COMPLETION}" -eq 1 ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
fi

unset SC_HAS_BREW_BASH_COMPLETION
