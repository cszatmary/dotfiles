### Setup general aliases ###

alias pn='pnpm'
alias px='pnpx'
alias pnr='pnpm run'

# lj - list jobs
alias lj='jobs'

alias clr='clear'
alias reload!='source ~/.zshrc'

# Switch to a bash login shell
alias bash!='exec bash --login'

alias lzd='lazydocker'

alias cat='bat'
alias ls='exa -lah'

# Show largest files
alias du='du -hs * | sort -hr'

### Setup variables ###

# Colors
GREEN="\e[38;5;46m"
MAGENTA="\e[38;5;161m"
BLUE="\e[38;5;27m"
WHITE="\e[38;5;255m"
ORANGE="\e[38;5;202m"
RED="\033[0;31m"

### Setup functions ###

update_dotfiles() {
    CURRENT_DIR="$(pwd)"
    cd ~/.dotfiles

    NO_UPDATE="Already up to date."
    if [[ "$(git pull)" == $NO_UPDATE ]]; then
        echo $NO_UPDATE
    else
        source ~/.zshrc
        echo "${GREEN}Successfully updated!"
    fi

    cd "$CURRENT_DIR"
}

# Change directories and list contents
# Can specify any ls options
cdl() {
	cd $1 && ls $2
}

# Creates a new directory and automatically changes into it
nwdir() {
    mkdir $1 && cd $1
}

# Prevent dangerious use of rm!
rm() {
    echo "${ORANGE}Using rm is highly discourage as the changes are irreversible. Consider using the trash function instead."
    read "shouldContinue?Are you sure you want to continue with rm? [y/n]: "

    # To be safe if anything other than y or yes is entered exit the function
    [[ "$shouldContinue" != 'y' && "$shouldContinue" != "yes" ]] && return 0;

    # Double check the arguments to make sure the user isn't trying to delete the root or home directory
    for arg in "$@"; do
        if [[ "$arg" == "/" || "$arg" == "~" ]]; then
            echo "${MAGENTA}ERROR! Do not delete $arg!" >&2
            exit 1;
        fi
    done

    echo "Deleting..."
    # Pass all arguments to the actual rm command
    command rm "$@"
}

serverprocess() {
    lsof -i TCP:"$1"
}

pid() {
    processes=$(ps -f)
    if [[ "$1" ]]; then
        echo "$processes" | grep "$1"
    else
        echo "$processes"
    fi
}

filecount() {
    if [[ "$#" -lt 1 ]]; then
        echo "${MAGENTA}Error: Must specify a string to match against."
        echo "Usage: filecount [MATCH_STRING] [OPTIONS]"
    fi

    if [[ "$1" == "--help" ]]; then
        echo "Counts how many files in the given directory contain a given string in their name."
        echo "Example: filecount .c"
        echo "Optionally the -r or --recursive flag can be passed which will recursively search all subdirectories as well."
    fi

    OPTIONS=""
    if [[ "$2" == "-r" || "$2" == "--recursive" ]]; then
        OPTIONS+="-R"
    fi

    count=$(ls $OPTIONS | grep "$1" | wc -l)
    echo "$count files found containing the string '$1'"
}

join_path() {
    echo ${(j:/:)@%/}
    # printf -n '%s/' "${@%/}"
}

mknote() {
    ext=$2
    if [[ -z $ext ]]; then
        ext="md"
    fi
    touch "$(date +%F)_$1.$ext"
}
