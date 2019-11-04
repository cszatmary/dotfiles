alias yg='yarn global'
alias ygout='yarn outdated --cwd $YARN_GLOBAL'

# lj - list jobs
alias lj='jobs'

alias clr='clear'
alias reload!='source ~/.zshrc'

# Switch to a bash login shell
alias bash!='exec bash --login'

alias nuke_node_modules='command rm -rf node_modules'

alias editconfig='vim ~/.zshrc'

alias lzd='lazydocker'

alias cat='bat'
alias ls='exa -lah'

# Show largest files
alias du='du -hs * | sort -hr'

# macOS only
if [[ "$OSTYPE" == "darwin"* ]]; then
    # brew cask aliases
    alias cask='brew cask'

    alias simctl='xcrun simctl'
fi
