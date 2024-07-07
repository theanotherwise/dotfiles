#!/bin/bash

SCRIPT_DIR_PATH="$(dirname "$(realpath "$0")")"

dotfiles_help() {
  echo "- - - -  -"
  echo -e "Script usage:\t/bin/bash ${0} macos/linux"
  echo
  echo -e "Script Dir:\t${SCRIPT_DIR_PATH}"
  echo -e "Script Name:\t${0}"
}

DOTFILES_DONE=false

if [ "${#}" == 1 ]; then
  if [ "${1}" == "macos" ]; then
    python3 ${SCRIPT_DIR_PATH}/.dotfiles/init.py "${1}"

    DOTFILES_DONE=true
  elif [ "${1}" == "linux" ]; then
    python3 ${SCRIPT_DIR_PATH}/.dotfiles/init.py "${1}"

    DOTFILES_DONE=true
  fi
fi

if [ "${DOTFILES_DONE}" != "true" ]; then
  dotfiles_help
fi
