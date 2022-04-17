#!/bin/bash

[ -z "$TMP_HOME" ] && TMP_HOME="${HOME}"

mkdir -p "${TMP_HOME}"/archives
mkdir -p "${TMP_HOME}"/binaries/helm
mkdir -p "${TMP_HOME}"/binaries/node
mkdir -p "${TMP_HOME}"/binaries/ruby
mkdir -p "${TMP_HOME}"/binaries/kubectl
mkdir -p "${TMP_HOME}"/binaries/terraform
mkdir -p "${TMP_HOME}"/binaries/yarn
mkdir -p "${TMP_HOME}"/downloads
mkdir -p "${TMP_HOME}"/configs
mkdir -p "${TMP_HOME}"/sessions
mkdir -p "${TMP_HOME}"/projects
mkdir -p "${TMP_HOME}"/scripts/cron.d
mkdir -p "${TMP_HOME}"/temporary

rm -f "${TMP_HOME}"/README.md "${TMP_HOME}"/.gitignore "${TMP_HOME}"/.dotfiles/initialize.sh

rm -rf "${TMP_HOME}"/.git
