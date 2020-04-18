#!/bin/bash

set -e

# Colours to use
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
CLEAR='\033[0m'

# Helper functions for logging

info() {
    printf "${CYAN}INFO: ${CLEAR}$1\n"
}

success() {
    printf "${GREEN}OK: ${CLEAR}$1\n"
}

fail() {
  printf "${RED}ERROR: ${CLEAR}$1\n"
  exit 1
}

# ----- START -----

if [[ $USER == 'root' ]]; then
    fail "Don't run this script as root"
fi

# Make sure it's a supported OS
if [[ "$OSTYPE" != "darwin"* && "$OSTYPE" != "linux-gnu" ]]; then
    fail 'Unsupported OS. Only macOS and linux are supported.'
fi

# Check if brew is installed
info "Checking if ${CYAN}homebrew${CLEAR} is installed..."

if ! command -v brew > /dev/null; then
  info "Installing ${CYAN}homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  success "Successfully installed ${CYAN}homebrew"
else
  info "${CYAN}homebrew${CLEAR} is already installed!"
fi

# Install from brewfile
info "Installing brew packages..."
brew bundle

# Set zsh as the default shell
info "Checking default shell"

if [[ "$(echo $SHELL | xargs basename)" == "zsh" ]]; then
  info "${CYAN}zsh${CLEAR} is already the default shell!"
else
  info "Setting default shell to ${CYAN}zsh"
  sudo chsh -s $(command -v zsh) "$USER"
  success "Changed default shell to zsh"
fi

# Install oh-my-zsh
info "Checking ${CYAN}oh-my-zsh"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "${CYAN}oh-my-zsh${CLEAR} is already installed!"
else
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    success "Successfully installed ${CYAN}oh-my-zsh"
fi

# Install dot to manage dotfiles
go get -u github.com/cszatma/dot
alias dot="$(go env GOPATH)/bin/dot"
dot setup -v
dot apply -v

# TODO figure this out for linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    mkdir -p "$HOME/Library/Application Support/VSCodium/User"
    info "Copying vscodium settings"
    cp ./vscodium/settings.json "$HOME/Library/Application Support/VSCodium/User/settings.json"
fi

# Configure vim
info "Configuring ${CYAN}vim"

if [[ ! -d "$HOME/.vim/bundle" ]]; then
    mkdir -p ~/.vim/bundle
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

vim +PluginInstall +qall

# Install macOS defaults
if [[ "$OSTYPE" == "darwin"* ]]; then
    info "Installing macOS defaults"
    ./macos/defaults.sh
fi

# Install rust
if ! command -v rustc > /dev/null; then
    info "Installing ${CYAN}rust"
    curl https://sh.rustup.rs -sSf | sh
else
    info "Rust is already installed!"
fi

# Install vscodium extensions

if ! command -v codium > /dev/null; then
    info "${CYAN}codium${CLEAR} command is not installed, please install it before continuing"
    read -p "Press enter to continue"
fi

info "Installing VSCodium extensions"
for ext in $(cat ./vscodium/Codefile); do
    codium --install-extension $ext
done

# Install spaceship theme
info "Installing spaceship theme for zsh"
git clone https://github.com/denysdovhan/spaceship-prompt.git ./zsh/themes/spaceship-prompt
cp ./zsh/themes/spaceship-prompt/spaceship.zsh-theme ./zsh/themes/spaceship.zsh-theme

# Installi the-one-theme
info "Installing the one theme"
mkdir -p ./.extras
git clone https://github.com/benniemosher/the-one-theme/ ./.extras/the-one-theme
info "the one theme is located at ${CYAN}$(pwd)/.extras/the-one-theme"

# Install powerline fonts
info "Installing powerline fonts"
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

success "All done. Enjoy!"
