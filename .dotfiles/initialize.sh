#!/bin/bash

function portable() {
  case "${1}" in
  helm)
    URL="https://get.helm.sh/helm-v${2}-linux-amd64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/helm.tgz"
    APP_DIR="${HOME}/binaries/helm"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}/bin" --strip-components=1
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  kubectl)
    URL="https://dl.k8s.io/release/v${2}/bin/linux/amd64/kubectl"
    ARCHIVE_PATH="${TMP_DIR}/kubectl"
    APP_DIR="${HOME}/binaries/kubectl"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    mv "${ARCHIVE_PATH}" "${APP_DIR}/${2}/bin"
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  yarn)
    URL="https://github.com/yarnpkg/yarn/releases/download/v${2}/yarn-v${2}.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/yarn.tgz"
    APP_DIR="${HOME}/binaries/yarn"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}" --strip-components=1
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  node)
    URL="https://nodejs.org/dist/v${2}/node-v${2}-linux-x64.tar.xz"
    ARCHIVE_PATH="${TMP_DIR}/node.xz"
    APP_DIR="${HOME}/binaries/node"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    tar -xf "${ARCHIVE_PATH}" -C "${APP_DIR}/${2}" --strip-components=1
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  terraform)
    URL="https://releases.hashicorp.com/terraform/${2}/terraform_${2}_linux_amd64.zip"
    ARCHIVE_PATH="${TMP_DIR}/terraform.zip"
    APP_DIR="${HOME}/binaries/terraform"

    mkdir -p "${APP_DIR}/${2}/bin"
    ln -s "${APP_DIR}/${2}" "${APP_DIR}/latest"
    wget "${URL}" -O "${ARCHIVE_PATH}" --quiet --show-progress
    unzip -j "${ARCHIVE_PATH}" -d "${APP_DIR}/${2}/bin"
    chmod 700 -R "${APP_DIR}/${2}/bin"
    ;;
  esac
}

TMP_DIR="$(mktemp -p "/tmp" -d XXXXX)"

mkdir -p "${HOME}"/archives
mkdir -p "${HOME}"/downloads
mkdir -p "${HOME}"/configs
mkdir -p "${HOME}"/sessions
mkdir -p "${HOME}"/projects
mkdir -p "${HOME}"/scripts/cron.d
mkdir -p "${HOME}"/temporary

mkdir -p "${HOME}"/binaries/helm
mkdir -p "${HOME}"/binaries/node
mkdir -p "${HOME}"/binaries/ruby
mkdir -p "${HOME}"/binaries/kubectl
mkdir -p "${HOME}"/binaries/terraform
mkdir -p "${HOME}"/binaries/yarn

portable "helm" "3.8.2"
portable "kubectl" "1.23.0"
portable "yarn" "1.22.18"
portable "node" "16.14.2"
portable "terraform" "1.1.8"

rm -f "${HOME}"/README.md
rm -f "${HOME}"/.gitignore
rm -f "${HOME}"/.dotfiles/initialize.sh
rm -rf "${HOME}"/.git
rm -rf "${TMP_DIR}"
