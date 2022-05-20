#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="$1"/logs/$(date '+%Y-%m-%d').log

touch $LOG_FILE

function showMessage () {
    printf '\n%b' "$1\\e[01;38;05;214m$2\\033[0m\n"
    echo -e "\n$1$2\n" >> $LOG_FILE
}

function showError () {
    printf '\n%b' "$1\\e[1;31m$2\\033[0m\n"
    echo -e "\n$1$2\n" >> $LOG_FILE
}

function checkDirs () {
    if [ ! -d "$1" ]; then
        showError "Doesn't exist repository directory: " "$1"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        showError "Doesn't exist backup dir: " "$2 "
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi
}

function goSync () {
    showMessage "" "Synchronization"
    rsync \
    --archive \
    --compress \
    --human-readable \
    --delete \
    --stats "$1" "$2" | tee -a $LOG_FILE
}

showMessage "" "-------------------->8--------------------"
showMessage "Start: " "$(date '+%Y-%m-%d %H:%M:%S')"
showMessage "Repository dir: " "$1"
showMessage "Backup dir: " "$2"

checkDirs "$1" "$2"

goSync "$1" "$2"

showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
