#!/bin/bash

set -e

# Colours to use
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
CLEAR='\033[0m'

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

copy_file() {
    if [[ -f $2 ]]; then
        info "Backing up ${CYAN}$2"
        mv $2 "$2.bak"
    fi

    info "Copying ${CYAN}$2${CLEAR} to ${CYAN}$1"
    cp $1 $2
}

if [[ $USER == 'root' ]]; then
    fail "Don't run this script as root"
fi

# Install homebrew/linuxbrew
if [[ "$OSTYPE" == "darwin"* ]]; then
    # OS is macOS
    BREW_NAME='homebrew'
    BREW_URL='https://raw.githubusercontent.com/Homebrew/install/master/install'
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    # OS is GNU/Linux
    BREW_NAME='linuxbrew'
    BREW_URL='https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh'
else
    fail 'Unsupported OS. Only macOS and linux are supported.'
fi

# Check if brew is installed
info "Checking if ${CYAN}$BREW_NAME ${CLEAR}is installed..."

if ! command -v brew > /dev/null; then
  info "Installing ${CYAN}$BREW_NAME"
  /usr/bin/ruby -e "$(curl -fsSL "$BREW_URL")"
  success "Successfully installed ${CYAN}$BREW_NAME"
else
  info "${CYAN}$BREW_NAME${CLEAR} is already installed!"
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

# Copy dotfiles
copy_file ./git/gitconfig "$HOME/.gitconfig"

mkdir -p "$HOME/.ssh"
copy_file ./ssh/config "$HOME/.ssh/config"

copy_file ./tmux.conf "$HOME/.tmux.conf"

copy_file ./vim/vimrc "$HOME/.vimrc"

mkdir -p "$HOME/Library/Application Support/VSCodium/User"
copy_file ./vscodium/settings.json "$HOME/Library/Application Support/VSCodium/User/settings.json"

copy_file ./zsh/zshrc "$HOME/.zshrc"

# Configure vim
info "Configuring ${CYAN}vim"
mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Install macOS defaults
info "Installing macOS defaults"
./macos/defaults.sh

# Install rust
info "Installing ${CYAN}rust"
curl https://sh.rustup.rs -sSf | sh

# Install vscodium extensions
info "Installing VSCodium extensions"
for ext in "$(cat ./vscodium/Codefile)"; do
    codium --install-extension $ext
done

# Install spaceship theme
info "Installing spaceship theme for zsh"
git clone https://github.com/denysdovhan/spaceship-prompt.git ./zsh/themes/spaceship-prompt
ln -s ./zsh/themes/spaceship-prompt/spaceship.zsh-theme ./zsh/themes/spaceship.zsh-theme

# Installi the-one-theme
info "Installing the one theme"
mkdir -p ./.extras
git clone https://github.com/benniemosher/the-one-theme/ ./.extras
info "the one theme is located at ${CYAN}$(pwd)/.extras/the-one-theme"

# Install powerline fonts
info "Installing powerline fonts"
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

success "All done. Enjoy!"
