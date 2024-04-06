if [[ "$OSTYPE" == "darwin"* ]]; then
    # Opens the specified application on macOS
    app() {
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
    }

    # Toggles visibility of hidden files on macOS
    toggleHidden() {
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
    }

    # Opens the given resource in Xcode
    xcode() {
        if [[ "$1" == "-v" ]]; then
            open $3 -a "/Applications/Xcode_$2.app"
        else
            open $1 -a "/Applications/Xcode.app"
        fi
    }

    # Opens the given resource in the browser specified in $WEB_BROWSER
    web() {
        if [[ -z $WEB_BROWSER ]]; then
            echo "WEB_BROWSER variable is not set"
            exit 1
        fi
        open $1 -a "$WEB_BROWSER"
    }
fi