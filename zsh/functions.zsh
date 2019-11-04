# Useful functions

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

trash() {
    if [[ "$1" == -a || "$1" == --all ]] ; then
		ALL="*"
		FILE="$2"
    elif [[ "$1" == -e || "$1" == --extension ]] ; then
		PREFIX="*"
		FILE=".""$2"
    else
		FILE="$1"
    fi
    mv $PREFIX"$FILE"$ALL ~/.Trash/
}

emptyTrash() {
    command rm -rf ~/.Trash/*
}

# Updates all brew dependencies
freshBrew() {
    command brew update
    echo "${ORANGE}Finding outdated packages."
    outdated=$(brew outdated)
    if [[ $outdated ]]; then
        echo "${WHITE}$outdated"
        printf "${ORANGE}Upgrade outdated packages? [y/n]: "
        read -q shouldUpgrade
        printf "\n"
        [[ "$shouldUpgrade" == 'y' ]] && command brew upgrade
    else
        echo "${MAGENTA}Everything is up to date."
    fi
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

# Opens the specified application on macOS
app() {
    # Make sure on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        IFS_backup=$IFS
        IFS=$'\n'
        # Get all applications that match the name provided
        APP_RESULTS=($(ls /Applications | grep "$1"))
        IFS=$IFS_backup
        # Handle no results found
        if [[ "${#APP_RESULTS[@]}" -eq 0 ]]; then
            echo "${RED}error: No application with name matching $1"
        # If one result found open it
        elif [[ "${#APP_RESULTS[@]}" -eq 1 ]]; then
            open "/Applications/${APP_RESULTS[1]}"
        # If multiple results found list them and let the user choose
        else
            echo "The following applications matching '$1' where found:"
            for ((i=1; i <= ${#APP_RESULTS[@]}; ++i)); do
                echo "$i": "${APP_RESULTS[i]}"
            done
            
            read "choice?Which application would you like to open? [default 1]: "
            [[ "${APP_RESULTS[$choice]}" == "" ]] && choice=1
            open "/Applications/${APP_RESULTS[$choice]}"
        fi
    else
        echo "${RED}error: app is currently only supported on macOS"
        exit 1
    fi
}

# Toggles visibility of hidden files on macOS
toggleHidden() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        DOMAIN="com.apple.finder"
        KEY="AppleShowAllFiles"

        if [[ "$(defaults read $DOMAIN $KEY)" == "true" ]]; then
            VALUE=false
        else
            VALUE=true
        fi

        defaults write $DOMAIN $KEY $VALUE
        killall Finder

        echo "Hidden files visible: $VALUE"
    else
        echo "${RED}error: toggleHidden is currently only supported on macOS"
        exit 1
    fi
}

# macOS Only
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Opens the given resource in Xcode 
    xcode() {
        if [[ "$1" == "-v" ]]; then
            open $3 -a "/Applications/Xcode_$2.app"
        else
            open $1 -a $XCODE
        fi
    }

    # Opens the given resource in the browser specified in $WEB_BROWSER
    web() {
        open $1 -a $WEB_BROWSER
    }
fi
