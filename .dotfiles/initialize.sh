#!/bin/bash

# Logger Colors
CONF_COLORS="true"

# Setup Default Versions
[ -z "${HELM_VERSION}" ]      && HELM_VERSION="3.10.1"
[ -z "${KUBECTL_VERSION}" ]   && KUBECTL_VERSION="1.25.3"
[ -z "${K3D_VERSION}" ]       && K3D_VERSION="5.4.3"
[ -z "${YARN_VERSION}" ]      && YARN_VERSION="1.22.19"
[ -z "${NODE_VERSION}" ]      && NODE_VERSION="16.18.0"
[ -z "${TERRAFORM_VERSION}" ] && TERRAFORM_VERSION="1.3.3"
[ -z "${PYTHON_VERSION}" ]    && PYTHON_VERSION="3.10.8"
[ -z "${RUBY_VERSION}" ]      && RUBY_VERSION="3.1.2"

# Directoriesto to Setup
directories=("archives" "downloads" "configs" "sessions" "projects" "scripts/cron.d" "temporary" "binaries")

# Setup Install Directory
if [ -z "${DOT_HOME}" ] ; then
  DOT_HOME="${HOME}"
fi

########################################################
function formatter () {
  DATE="`date +\"%Y-%m-%d %H:%M:%S,%3N\"`"

  if [[ "${CONF_COLORS}" == "true" ]] ; then
    echo -e "${DATE} \e[${3}m${1}\e[m\t ${2}"
  else
    echo -e "${DATE} ${1}\t ${2}"
  fi
}

function messager () {
  if [ "${#}" -eq "2" ] ; then
    if [ "${2}" == "error" ] ; then
      formatter "ERROR" "${1}" "91"
    elif [ "${2}" == "success" ] ; then
      formatter "SUCCESS" "${1}" "92"
    elif [ "${2}" == "warning" ] ; then
      formatter "WARNING" "${1}" "93"
    elif [ "${2}" == "info" ] ; then
      formatter "INFO" "${1}" "96"
    else
      formatter "LOGGER" "Incorrect logger type: '${2}'.." "31" && exit 4
    fi
  elif [ "${#}" -eq "1" ] ; then
    formatter "INFO" "${1}" "0"
  fi
}

function logger () {
  [ "${#}" -lt 1 ] || [ "${#}" -gt 2 ] && exit 1

  if [ "${#}" -eq "1" ] ; then
    [ -z "${1}" ] && exit 2 || messager "${1}"
  fi

  if [ "${#}" -eq "2" ] ; then
    [ -z "${1}" ] || [ -z "${2}" ] && exit 3 || messager "${2}" "${1}"
  fi
}

function portable_dir () {
  logger "info" "Create directory '${1}'"
  mkdir -p "${1}"
}

function portable_symlink () {
  logger "info" "Create symlink '${2}' -> '${1}'"
  ln -s "${1}" "${2}"
}

function portable_download () {
  logger "info" "Download file '${1}' -> '${2}'"
  wget "${1}" -O "${2}" --quiet
}

function portable_permissions () {
  logger "info" "Fix permissions in '${1}'"
  chmod 700 --recursive --silent "${1}"
}

function portable_extract_tar () {
  logger "info" "Extract tar archive '${1}' -> '${2}'"
  tar -xf "${1}" -C "${2}" --strip-components=1
}

function portable_compile () {
  logger "info" "Enter to '${1}' directory"
  cd "${1}"
  logger "info" "Configure compilation '${1}' with --prefix '${2}'"
  ./configure --prefix="${2}" 2>&1 > /dev/null
  logger "info" "Compile package '${1}'"
  make CDBG=-w 2>&1 > /dev/null
  logger "info" "Install compiled to '${2}'"
  make install 2>&1 > /dev/null
  logger "info" "Exit to '${HOME}' from '${1}' directory"
  cd
}

function portable () {
  logger "info" "Install package '${1}', Version: '${2}'"
  case "${1}" in
  helm)
    URL="https://get.helm.sh/helm-v${2}-linux-amd64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/helm.tgz"
    APP_DIR="${DOT_HOME}/binaries/helm"

    portable_dir "${APP_DIR}/${2}/bin"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    portable_permissions "${APP_DIR}/${2}/bin"
    ;;
  kubectl)
    URL="https://dl.k8s.io/release/v${2}/bin/linux/amd64/kubectl"
    ARCHIVE_PATH="${TMP_DIR}/kubectl"
    APP_DIR="${DOT_HOME}/binaries/kubectl"

    portable_dir "${APP_DIR}/${2}/bin"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    mv "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    portable_permissions "${APP_DIR}/${2}/bin"
    ;;
  yarn)
    URL="https://github.com/yarnpkg/yarn/releases/download/v${2}/yarn-v${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/yarn.tgz"
    APP_DIR="${DOT_HOME}/binaries/yarn"

    portable_dir "${APP_DIR}/${2}/bin"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${APP_DIR}/${2}"
    portable_permissions "${APP_DIR}/${2}/bin"
    ;;
  node)
    URL="https://nodejs.org/dist/v${2}/node-v${2}-linux-x64.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/node.xz"
    APP_DIR="${DOT_HOME}/binaries/node"

    portable_dir "${APP_DIR}/${2}/bin"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${APP_DIR}/${2}"
    portable_permissions "${APP_DIR}/${2}/bin"
    ;;
  terraform)
    URL="https://releases.hashicorp.com/terraform/${2}/terraform_${2}_linux_amd64.zip"
    ARCHIVE_PATH="${TMP_DIR}/terraform.zip"
    APP_DIR="${DOT_HOME}/binaries/terraform"

    portable_dir "${APP_DIR}/${2}/bin"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    unzip -j -qq -f "${ARCHIVE_PATH}" -d "${APP_DIR}/${2}/bin"
    portable_permissions "${APP_DIR}/${2}/bin"
    ;;
  python)
    URL="https://www.python.org/ftp/python/${2}/Python-${2}.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/python.tar.xz"
    APP_DIR="${DOT_HOME}/binaries/python"
    BUILD_DIR="${TMP_DIR}/python"

    mkdir -p "${APP_DIR}/${2}" "${BUILD_DIR}"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BUILD_DIR}"
    portable_compile "${BUILD_DIR}" "${APP_DIR}/${2}"
    ;;
  ruby)
    URL="https://cache.ruby-lang.org/pub/ruby/${2:0:3}/ruby-${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/ruby.tar.xz"
    APP_DIR="${DOT_HOME}/binaries/ruby"
    BUILD_DIR="${TMP_DIR}/ruby"

    mkdir -p "${APP_DIR}/${2}" "${BUILD_DIR}"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    portable_extract_tar "${ARCHIVE_PATH}" "${BUILD_DIR}"
    portable_compile "${BUILD_DIR}" "${APP_DIR}/${2}"
    ;;
  k3d)
    URL="https://github.com/k3d-io/k3d/releases/download/v${2}/k3d-linux-amd64"
    ARCHIVE_PATH="${TMP_DIR}/k3d"
    APP_DIR="${DOT_HOME}/binaries/k3d"

    portable_dir "${APP_DIR}/${2}/bin"
    portable_symlink "${APP_DIR}/${2}" "${APP_DIR}/latest"
    portable_download "${URL}" "${ARCHIVE_PATH}"
    mv "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    portable_permissions "${APP_DIR}/${2}/bin"
    ;;
  esac
}

function install_deps () {
  apt-get update -qq
  xargs -a "${1}/.dotfiles/packages.list" apt-get -y -qq install 
}

function home_dirs () {
  HOME_DIRS=("${@}")
  for DIR in "${HOME_DIRS[@]}" ; do
    mkdir -p "${DOT_HOME}/${DIR}"
  done
}

function cleanup () {
  rm -f "${1}"/README.md
  rm -f "${1}"/.gitignore
  rm -f "${1}"/.dotfiles/initialize.sh
  rm -rf "${1}"/.git
}

########################################################
# Main

logger "info" "Setup HOME directories in '${DOT_HOME}'"
home_dirs "${directories[@]}"

logger "info" "Install APT dependencies"
install_deps "${DOT_HOME}"

if [ "${INSTALL_PORTABLE}" == "yes" ] ; then
  TMP_DIR="$(mktemp -p "/tmp" -d XXXXX)"

  portable "helm"       "${HELM_VERSION}"
  portable "kubectl"    "${KUBECTL_VERSION}"
  portable "k3d"        "${K3D_VERSION}"
  portable "yarn"       "${YARN_VERSION}"
  portable "node"       "${NODE_VERSION}"
  portable "terraform"  "${TERRAFORM_VERSION}"
  portable "python"     "${PYTHON_VERSION}"
  portable "ruby"       "${RUBY_VERSION}"

  logger "info" "Remove '${TMP_DIR}' temporary directory"
  rm -rf "${TMP_DIR}"
fi

logger "info" "Cleanup temporary files"
cleanup "${DOT_HOME}"
