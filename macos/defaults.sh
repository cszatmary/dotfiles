#!/bin/bash

# Sets macOS defaults

##### Finder #####
# Open everything in column view
defaults write com.apple.Finder FXPreferredViewStyle clmv
# Show the ~/Library folder.
chflags nohidden ~/Library
# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

##### Dock #####
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Don't show recently used applications in the Dock
defaults write com.Apple.Dock show-recents -bool false

##### General #####
# Switch to dark mode
sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true
# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

##### Dock Applications #####
dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Music.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/Xcode.app"
dockutil --no-restart --add "/Applications/Brave Browser.app"
dockutil --no-restart --add "/Applications/Firefox Developer Edition.app"
dockutil --no-restart --add "/Applications/iTerm.app"
dockutil --no-restart --add "/Applications/System Preferences.app"

dockutil --no-restart --add "/Applications" --view grid --display folder --section others --sort name
dockutil --no-restart --add "~/Documents" --view grid --display folder --section others --sort name
dockutil --no-restart --add "~/Downloads" --view grid --display folder --section others --sort dateadded

##### Restart Apps ######
for app in "Dock" "Finder"; do
    killall "$app" &> /dev/null
done
