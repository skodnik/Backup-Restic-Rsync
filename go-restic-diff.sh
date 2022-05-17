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
    jq -r ".[0].id, .[0].parent"
}

function diffSnapshots () {
    showMessage "" "Diff previous and latest snapshots"
    restic \
    --repo "$1" \
    --password-file "$1"/.pass \
    diff $(getSnapshotsHash "$1") |\
    awk '($1=="+")' |\
    cut -f 2- -d ' ' |\
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

checkDirs "$1"
diffSnapshots "$1"

showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"