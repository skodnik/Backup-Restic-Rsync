#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="$1"/logs/$(date '+%Y-%m-%d').log

touch $LOG_FILE

function showMessage () {
    printf '\n%b' "$1\\e[01;38;05;214m$2\\033[0m\n" 
    echo -e "\n$1$2\n" >> $LOG_FILE
}

function checkDirs () {
    if [ ! -d "$1" ]; then
        showMessage "" "Repository directory $1 doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi

    if [ ! -d "$1/logs" ]; then
        showMessage "" "Logs dir doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi

    if [ ! -f "$1/.pass" ]; then
        showMessage "" "Password file doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi
}

function getSnapshotsHash () {
    restic \
    --repo "$1" \
    --password-file "$1"/.pass \
    snapshots \
    --json latest |\
    jq -r ".[0].parent, .[0].id"
}

SNAPSHOTS=$(getSnapshotsHash "$1")

function diffSnapshots () {
    showMessage "" "Diff between previous and last snapshots"
    restic \
    --repo "$1" \
    --password-file "$1"/.pass \
    diff $SNAPSHOTS |\
    tree --fromfile .  |\
    tee -a $LOG_FILE
}

if [ -f "$1"/.env ]; then
    export $(grep -v '^#' "$1"/.env | xargs)
else
    showMessage "" ".env file doesn't exist"
    showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
    exit 1
fi

showMessage "" "-------------------->8--------------------"
showMessage "Start: " "$(date '+%Y-%m-%d %H:%M:%S')"
showMessage "Repository: " "$1"
showMessage "Snapshots: " "\n$SNAPSHOTS"

checkDirs "$1"
diffSnapshots "$1"

showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"