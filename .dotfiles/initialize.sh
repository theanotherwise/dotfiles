#!/bin/bash

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
function portable() {
  case "${1}" in
  helm)
    URL="https://get.helm.sh/helm-v${2}-linux-amd64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/helm.tgz"
    APP_DIR="${DOT_HOME}/binaries/helm"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}/bin" --strip-components=1
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  kubectl)
    URL="https://dl.k8s.io/release/v${2}/bin/linux/amd64/kubectl"
    ARCHIVE_PATH="${TMP_DIR}/kubectl"
    APP_DIR="${DOT_HOME}/binaries/kubectl"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    mv "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  yarn)
    URL="https://github.com/yarnpkg/yarn/releases/download/v${2}/yarn-v${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/yarn.tgz"
    APP_DIR="${DOT_HOME}/binaries/yarn"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}" --strip-components=1
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  node)
    URL="https://nodejs.org/dist/v${2}/node-v${2}-linux-x64.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/node.xz"
    APP_DIR="${DOT_HOME}/binaries/node"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}" --strip-components=1
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  terraform)
    URL="https://releases.hashicorp.com/terraform/${2}/terraform_${2}_linux_amd64.zip"
    ARCHIVE_PATH="${TMP_DIR}/terraform.zip"
    APP_DIR="${DOT_HOME}/binaries/terraform"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    unzip -j "${ARCHIVE_PATH}" -d "${APP_DIR}/${2}/bin"
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  python)
    URL="https://www.python.org/ftp/python/${2}/Python-${2}.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/python.tar.xz"
    APP_DIR="${DOT_HOME}/binaries/python"
    BUILD_DIR="${TMP_DIR}/python"

    mkdir -p "${APP_DIR}/${2}" "${BUILD_DIR}"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${BUILD_DIR}" --strip-components=1
    cd "${BUILD_DIR}"
    ./configure --prefix="${APP_DIR}/${2}" --silent
    make --silent
    make install --silent
    cd
    ;;
  ruby)
    URL="https://cache.ruby-lang.org/pub/ruby/${2:0:3}/ruby-${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/ruby.tar.xz"
    APP_DIR="${DOT_HOME}/binaries/ruby"
    BUILD_DIR="${TMP_DIR}/ruby"

    mkdir -p "${APP_DIR}/${2}" "${BUILD_DIR}"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${BUILD_DIR}" --strip-components=1
    cd "${BUILD_DIR}"
    ./configure --prefix="${APP_DIR}/${2}" --silent
    make --silent
    make install --silent
    cd
    ;;
  k3d)
    URL="https://github.com/k3d-io/k3d/releases/download/v${2}/k3d-linux-amd64"
    ARCHIVE_PATH="${TMP_DIR}/k3d"
    APP_DIR="${DOT_HOME}/binaries/k3d"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    mv "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  esac
}

function install () {
  apt-get update
  xargs -a "${1}/.dotfiles/packages.list" apt-get -y install 
}

function setup() {
  arr=("${@}")
  for DIR in "${arr[@]}" ; do
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

setup "${directories[@]}"
install "${DOT_HOME}"

if [ "${INSTALL_PORTABLE}" == "yes" ] ; then
  TMP_DIR="$(mktemp -p "/tmp" -d XXXXX)"

  portable "${HELM_VERSION}"
  portable "${KUBECTL_VERSION}"
  portable "${K3D_VERSION}"
  portable "${YARN_VERSION}"
  portable "${NODE_VERSION}"
  portable "${TERRAFORM_VERSION}"
  portable "${PYTHON_VERSION}"
  portable "${RUBY_VERSION}"

  rm -rf "${TMP_DIR}"
fi

cleanup "${DOT_HOME}"
