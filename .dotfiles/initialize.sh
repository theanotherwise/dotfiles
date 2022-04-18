#!/bin/bash

[ -z "$TMP_HOME" ] && TMP_HOME="${HOME}"

mkdir -p "${TMP_HOME}"/archives
mkdir -p "${TMP_HOME}"/downloads
mkdir -p "${TMP_HOME}"/configs
mkdir -p "${TMP_HOME}"/sessions
mkdir -p "${TMP_HOME}"/projects
mkdir -p "${TMP_HOME}"/scripts/cron.d
mkdir -p "${TMP_HOME}"/temporary

mkdir -p "${TMP_HOME}"/binaries/helm/bin
mkdir -p "${TMP_HOME}"/binaries/node/bin
mkdir -p "${TMP_HOME}"/binaries/ruby/bin
mkdir -p "${TMP_HOME}"/binaries/kubectl/bin
mkdir -p "${TMP_HOME}"/binaries/terraform/bin
mkdir -p "${TMP_HOME}"/binaries/yarn/bin

rm -f "${TMP_HOME}"/README.md
rm -f "${TMP_HOME}"/.gitignore
rm -f "${TMP_HOME}"/.dotfiles/initialize.sh
rm -rf "${TMP_HOME}"/.git
