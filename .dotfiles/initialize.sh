#!/bin/bash

CONF_COLORS="true"

[ -z "${K3D_VERSION}" ] && K3D_VERSION="5.4.9"
[ -z "${KUBECTL_VERSION}" ] && KUBECTL_VERSION="1.26.3"
[ -z "${OKD_VERSION}" ] && OKD_VERSION="3.11.0-0cbc58b+4.10.0-0.okd-2022-03-07-131213"
[ -z "${HELM_VERSION}" ] && HELM_VERSION="3.11.2"
[ -z "${KUSTOMIZE_VERSION}" ] && KUSTOMIZE_VERSION="4.5.7"
[ -z "${NODE_VERSION}" ] && NODE_VERSION="18.15.0"
[ -z "${YARN_VERSION}" ] && YARN_VERSION="1.22.19"
[ -z "${TERRAFORM_VERSION}" ] && TERRAFORM_VERSION="1.4.4"
[ -z "${PYTHON_VERSION}" ] && PYTHON_VERSION="3.11.2"
[ -z "${RUBY_VERSION}" ] && RUBY_VERSION="3.2.2"
[ -z "${UPX_VERSION}" ] && UPX_VERSION="4.0.2"

directories=("archives" "downloads" "configs" "sessions" "projects" "scripts/cron.d" "temporary" "binaries")

if [ -z "${DOT_HOME}" ]; then
  DOT_HOME="${HOME}"
fi

########################################################
function logger_format() {
  DATE=$(date +"%Y-%m-%d %H:%M:%S,%3N")

  if [[ "${CONF_COLORS}" == "true" ]]; then
    echo -e "${DATE} \e[${3}m${1}\e[m\t ${2}"
  else
    echo -e "${DATE} ${1}\t ${2}"
  fi
}

function logger_msg() {
  if [ "${2}" == "error" ]; then
    logger_format "ERROR" "${1}" "91"
  elif [ "${2}" == "success" ]; then
    logger_format "SUCCESS" "${1}" "92"
  elif [ "${2}" == "warning" ]; then
    logger_format "WARNING" "${1}" "93"
  elif [ "${2}" == "info" ]; then
    logger_format "INFO" "${1}" "96"
  else
    logger_format "LOGGER" "Incorrect logger type: '${2}'.." "31" && exit 4
  fi
}

function logger() {
  [ "${#}" -lt 2 ] || [ "${#}" -gt 2 ] && exit 1

  logger_msg "${2}" "${1}"
}

function portable_dir() {
  logger "info" "Create directory '${1}'"
  mkdir -p "${1}"
}

function portable_symlink() {
  logger "info" "Create symlink '${2}' -> '${1}'"

  CREATE_SYMLINK="yes"

  if [ -L "${2}" ]; then
    CREATE_SYMLINK="no"
    logger "warning" "Symlink already exists, override [Yes/no]?"
    while true; do
      read -p "Answer: " OVERRIDE
      echo "${OVERRIDE}"
      if [ "${OVERRIDE}" == "no" ] || [ "${OVERRIDE}" == "Yes" ]; then
        if [ "${OVERRIDE}" == "Yes" ]; then
          CREATE_SYMLINK="yes"
        fi

        break
      fi
    done

    logger "info" "Removing symlink ${2}"
    rm -f "${2}"
  fi

  if [ "${CREATE_SYMLINK}" == "yes" ]; then
    logger "info" "Creating symlink '${2}' -> '${1}'"
    ln -s "${1}" "${2}"
  fi
}

function portable_download() {
  logger "info" "Download file '${1}' -> '${2}'"
  wget "${1}" -O "${2}" --quiet
}

function portable_permissions() {
  logger "info" "Fix permissions in '${1}'"
  chmod 700 --recursive --silent "${1}"
}

function portable_extract_tar() {
  logger "info" "Extract TAR archive '${1}' -> '${2}'"

  if [ "${3}" == "strip" ]; then
    tar -xf "${1}" -C "${2}" --strip-components=1
  else
    tar -xf "${1}" -C "${2}"
  fi
}

function portable_extract_zip() {
  logger "info" "Extract ZIP archive '${1}' -> '${2}'"
  unzip -qqo "${1}" -d "${2}"
}

function portable_compile() {
  MAKE_CORES="$(grep -c '^processor' /proc/cpuinfo)"
  MAKEFLAGS="-j$((MAKE_CORES + 1)) -l${MAKE_CORES}"

  export MAKEFLAGS

  logger "info" "Enter to '${1}' directory"
  cd "${1}"
  logger "info" "Configure compilation '${1}' with --prefix '${2}'"
  ./configure --prefix="${2}" >/dev/null 2>&1
  logger "info" "Compile package '${1}'"
  make >/dev/null 2>&1
  logger "info" "Install compiled to '${2}'"
  make install >/dev/null 2>&1
  logger "info" "Exit to '${HOME}' from '${1}' directory"
  cd
}

function portable() {
  logger "info" "Install package '${1}', Version: '${2}'"
  case "${1}" in
  helm)
    URL="https://get.helm.sh/helm-v${2}-linux-amd64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/helm.tgz"

    APP_PATH="${DOT_HOME}/binaries/helm"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BIN_PATH}" "strip"
    portable_permissions "${BIN_PATH}"
    ;;
  kubectl)
    URL="https://dl.k8s.io/release/v${2}/bin/linux/amd64/kubectl"
    ARCHIVE_PATH="${TMP_DIR}/kubectl"

    APP_PATH="${DOT_HOME}/binaries/kubectl"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    mv "${ARCHIVE_PATH}" "${BIN_PATH}"
    portable_permissions "${BIN_PATH}"
    ;;
  kustomize)
    URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${2}/kustomize_v${2}_linux_amd64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/kustomize.tar.gz"

    APP_PATH="${DOT_HOME}/binaries/kustomize"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BIN_PATH}"
    portable_permissions "${BIN_PATH}"
    ;;
  yarn)
    URL="https://github.com/yarnpkg/yarn/releases/download/v${2}/yarn-v${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/yarn.tgz"

    APP_PATH="${DOT_HOME}/binaries/yarn"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${VER_PATH}" "strip"
    portable_permissions "${BIN_PATH}"
    ;;
  node)
    URL="https://nodejs.org/dist/v${2}/node-v${2}-linux-x64.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/node.tar.xz"

    APP_PATH="${DOT_HOME}/binaries/node"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"

    portable_dir "${VER_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${VER_PATH}" "strip"
    portable_permissions "${BIN_PATH}"
    ;;
  terraform)
    URL="https://releases.hashicorp.com/terraform/${2}/terraform_${2}_linux_amd64.zip"
    ARCHIVE_PATH="${TMP_DIR}/terraform.zip"

    APP_PATH="${DOT_HOME}/binaries/terraform"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_zip "${ARCHIVE_PATH}" "${BIN_PATH}"
    portable_permissions "${BIN_PATH}"
    ;;
  python)
    URL="https://www.python.org/ftp/python/${2}/Python-${2}.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/python.tar.xz"

    APP_PATH="${DOT_HOME}/binaries/python"
    BUILD_DIR="${TMP_DIR}/python"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"

    mkdir -p "${VER_PATH}" "${BUILD_DIR}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BUILD_DIR}" "strip"
    portable_compile "${BUILD_DIR}" "${VER_PATH}"
    ;;
  ruby)
    URL="https://cache.ruby-lang.org/pub/ruby/${2:0:3}/ruby-${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/ruby.tar.xz"

    APP_PATH="${DOT_HOME}/binaries/ruby"
    BUILD_PATH="${TMP_DIR}/ruby"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"

    mkdir -p "${VER_PATH}" "${BUILD_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BUILD_PATH}" "strip"
    portable_compile "${BUILD_PATH}" "${VER_PATH}"
    ;;
  k3d)
    URL="https://github.com/k3d-io/k3d/releases/download/v${2}/k3d-linux-amd64"
    ARCHIVE_PATH="${TMP_DIR}/k3d"

    APP_PATH="${DOT_HOME}/binaries/k3d"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    mv "${ARCHIVE_PATH}" "${BIN_PATH}"
    portable_permissions "${BIN_PATH}"
    ;;
  upx)
    URL="https://github.com/upx/upx/releases/download/v${2}/upx-${2}-amd64_linux.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/upx.tar.xz"

    APP_PATH="${DOT_HOME}/binaries/upx"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BIN_PATH}" "strip"
    portable_permissions "${BIN_PATH}"
    ;;
  okd)
    URL="https://github.com/seemscloud/okd-cli/archive/refs/tags/v${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/okd.tar.gz"

    APP_PATH="${DOT_HOME}/binaries/okd"
    LATEST_LINK="${APP_PATH}/latest"
    VER_PATH="${APP_PATH}/${2}"
    BIN_PATH="${VER_PATH}/bin"

    portable_dir "${BIN_PATH}"
    portable_symlink "${VER_PATH}" "${LATEST_LINK}"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BIN_PATH}" "strip"
    portable_permissions "${BIN_PATH}"
    ;;
  esac
}

function install_deps() {
  sudo -i apt-get update -qq
  xargs -a "${1}/.dotfiles/packages.list" sudo -i apt-get -y -qq install
}

function home_dirs() {
  HOME_DIRS=("${@}")
  for DIR in "${HOME_DIRS[@]}"; do
    mkdir -p "${DOT_HOME}/${DIR}"
  done
}

function cleanup() {
  rm -f "${DOT_HOME}"/README.md
  rm -f "${DOT_HOME}"/.gitignore
  rm -rf "${DOT_HOME}"/.git
  rm -rf "${TMP_DIR}"
}

function package_version() {
  TO_EXEC="${@}"

  echo
  logger "success" "Package '${1}', version:"
  eval "${TO_EXEC}"
}

function versions() {
  package_version k3d --version
  package_version kubectl version --output yaml
  package_version kubectl3.11 version
  package_version oc3.11 version
  package_version kubectl4.10 version
  package_version oc4.10 version
  package_version helm version
  package_version kustomize version
  package_version node --version
  package_version npm --version
  package_version yarn --version
  package_version terraform --version
  package_version upx --version
  package_version python3 --version
  package_version ruby --version
  package_version gem --version
}

########################################################
# Main

logger "info" "Setup HOME directories in '${DOT_HOME}'"
home_dirs "${directories[@]}"

logger "info" "Install APT dependencies"
install_deps "${DOT_HOME}"

if [ "${INSTALL_PORTABLE}" == "yes" ]; then
  TMP_DIR="$(mktemp -p "/tmp" -d XXXXX)"

  portable "k3d" "${K3D_VERSION}"
  portable "kubectl" "${KUBECTL_VERSION}"
  portable "okd" "${OKD_VERSION}"
  portable "helm" "${HELM_VERSION}"
  portable "kustomize" "${KUSTOMIZE_VERSION}"
  portable "node" "${NODE_VERSION}"
  portable "yarn" "${YARN_VERSION}"
  portable "terraform" "${TERRAFORM_VERSION}"
  portable "python" "${PYTHON_VERSION}"
  portable "ruby" "${RUBY_VERSION}"
  portable "upx" "${UPX_VERSION}"
fi

logger "info" "Cleanup temporary files"
cleanup

logger "info" "Reload '.bash_profile' file"
source "${DOT_HOME}/.bash_profile"

versions
