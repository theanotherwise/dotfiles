#!/bin/bash

function portable() {
  case "${1}" in
  helm)
    URL="https://get.helm.sh/helm-v${2}-linux-amd64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/helm.tgz"
    APP_DIR="${TMP_HOME}/binaries/helm"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}/bin" --strip-components=1
    ;;
  kubectl)
    URL="https://dl.k8s.io/release/v${2}/bin/linux/amd64/kubectl"
    ARCHIVE_PATH="${TMP_DIR}/kubectl"
    APP_DIR="${TMP_HOME}/binaries/kubectl"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    mv "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    ;;
  yarn)
    URL="https://github.com/yarnpkg/yarn/releases/download/v${2}/yarn-v${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/yarn.tgz"
    APP_DIR="${TMP_HOME}/binaries/yarn"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}" --strip-components=1
    ;;
  node)
    URL="https://nodejs.org/dist/v${2}/node-v${2}-linux-x64.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/node.xz"
    APP_DIR="${TMP_HOME}/binaries/node"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}" --strip-components=1
    ;;
  terraform)
    URL="https://releases.hashicorp.com/terraform/${2}/terraform_${2}_linux_amd64.zip"
    ARCHIVE_PATH="${TMP_DIR}/terraform.zip"
    APP_DIR="${TMP_HOME}/binaries/terraform"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    unzip -j "${ARCHIVE_PATH}" -d "${APP_DIR}/${2}/bin"
    ;;
  esac
}

[ -z "$TMP_HOME" ] && TMP_HOME="${HOME}"
TMP_DIR="$(mktemp -p "/tmp" -d XXXXX)"

mkdir -p "${TMP_HOME}"/archives
mkdir -p "${TMP_HOME}"/downloads
mkdir -p "${TMP_HOME}"/configs
mkdir -p "${TMP_HOME}"/sessions
mkdir -p "${TMP_HOME}"/projects
mkdir -p "${TMP_HOME}"/scripts/cron.d
mkdir -p "${TMP_HOME}"/temporary

mkdir -p "${TMP_HOME}"/binaries/helm
mkdir -p "${TMP_HOME}"/binaries/node
mkdir -p "${TMP_HOME}"/binaries/ruby
mkdir -p "${TMP_HOME}"/binaries/kubectl
mkdir -p "${TMP_HOME}"/binaries/terraform
mkdir -p "${TMP_HOME}"/binaries/yarn

portable "helm" "3.8.2"
portable "kubectl" "1.23.0"
portable "yarn" "1.22.18"
portable "node" "16.14.2"
portable "terraform" "1.1.8"

rm -f "${TMP_HOME}"/README.md
rm -f "${TMP_HOME}"/.gitignore
rm -f "${TMP_HOME}"/.dotfiles/initialize.sh
rm -rf "${TMP_HOME}"/.git
rm -rf "${TMP_DIR}"
