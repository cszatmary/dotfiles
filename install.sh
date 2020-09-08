#!/bin/bash

set -e

# Colours to use
RED='\033[0;31m'
CYAN='\033[0;36m'
CLEAR='\033[0m'

# Helper functions for logging

info() {
    printf "${CYAN}INFO: ${CLEAR}$1\n"
}

fail() {
  printf "${RED}ERROR: ${CLEAR}$1\n"
  exit 1
}

if [[ $USER == 'root' ]]; then
    fail "Don't run this script as root"
fi

INSTALL_DIR="$HOME/.dotfiles"
if [[ -d "$INSTALL_DIR" ]]; then
    fail "$INSTALL_DIR already exists!"
fi

# Use https since this will likely be run before ssh keys are setup
info "Cloning dotfiles to ${CYAN}$INSTALL_DIR"
git clone https://github.com/cszatmary/dotfiles.git "$INSTALL_DIR"

info "Running ${CYAN}bootstrap.sh"
cd "$INSTALL_DIR"
./bootstrap.sh
