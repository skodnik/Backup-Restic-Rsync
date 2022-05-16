#!/usr/bin/env bash

set -euo pipefail

function showMessage () {
    printf '\n%b' "$1\\e[01;38;05;214m$2\\033[0m\n"
}

function checkDirs () {
    if [ ! -d "$1" ]; then
        showMessage "" "Repository directory $1 doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        showMessage "" "Backup dir $2 doesn't exist"
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
    --stats "$1" "$2"
}

showMessage "" "-------------------->8--------------------"
showMessage "Start: " "$(date '+%Y-%m-%d %H:%M:%S')"
showMessage "Repository dir: " "$1"
showMessage "Backup dir: " "$2"

goSync "$1" "$2"

showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
