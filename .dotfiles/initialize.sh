#!/bin/bash

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
  esac
}

if [ -z "${DOT_HOME}" ] ; then
  DOT_HOME="${HOME}"
fi

mkdir -p "${DOT_HOME}"/archives
mkdir -p "${DOT_HOME}"/downloads
mkdir -p "${DOT_HOME}"/configs
mkdir -p "${DOT_HOME}"/sessions
mkdir -p "${DOT_HOME}"/projects
mkdir -p "${DOT_HOME}"/scripts/cron.d
mkdir -p "${DOT_HOME}"/temporary
mkdir -p "${DOT_HOME}"/binaries

if [ "${INSTALL_PORTABLE}" == "yes" ] ; then
  TMP_DIR="$(mktemp -p "/tmp" -d XXXXX)"
  
  [ -z "${HELM_VERSION}" ]      && portable "helm"      "3.8.2"  || portable "helm"      "${HELM_VERSION}"
  [ -z "${KUBECTL_VERSION}" ]   && portable "kubectl"   "1.23.0" || portable "kubectl"   "${KUBECTL_VERSION}"
  [ -z "${YARN_VERSION}" ]      && portable "yarn"      "3.8.2"  || portable "yarn"      "${YARN_VERSION}"
  [ -z "${NODE_VERSION}" ]      && portable "node"      "3.8.2"  || portable "node"      "${NODE_VERSION}"
  [ -z "${TERRAFORM_VERSION}" ] && portable "terraform" "3.8.2"  || portable "terraform" "${TERRAFORM_VERSION}"
  
  rm -rf "${TMP_DIR}"
fi

rm -f "${DOT_HOME}"/README.md
rm -f "${DOT_HOME}"/.gitignore
rm -f "${DOT_HOME}"/.dotfiles/initialize.sh
rm -rf "${DOT_HOME}"/.git
