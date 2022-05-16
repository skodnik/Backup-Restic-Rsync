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

    if [ ! -d "$2" ]; then
        showMessage "" "Working dir $2 doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi

    if [ ! -d "$1/logs" ]; then
        showMessage "" "Logs dir doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi

    if [ ! -f "$1/pass.txt" ]; then
        showMessage "" "Password file doesn't exist"
        showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
        exit 1
    fi
}

function checkRepo () {
    showMessage "" "Check repository"
    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    check \
    --read-data | tee -a $LOG_FILE
}

function showSnapshots () {
    showMessage "" "Show snapshots"
    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    snapshots | tee -a $LOG_FILE
}

function cleanUp () {
    showMessage "" "Cleaning up"
    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    forget \
    --keep-last 5 \
    --keep-hourly 12 \
    --keep-daily 28 \
    --keep-weekly 8 \
    --keep-monthly 12 \
    --keep-yearly 4 \
    --prune | tee -a $LOG_FILE

    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    cache \
    --cleanup | tee -a $LOG_FILE
}

function createSnashot () {
    showMessage "" "Create snapshot"
    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    --exclude-file=.resticignore \
    backup \
    "$2" | tee -a $LOG_FILE
}

function showStats () {
    showMessage "" "Statistics"
    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    stats \
    --mode restore-size \
    latest | tee -a $LOG_FILE

    restic \
    --repo "$1" \
    --password-file "$1"/pass.txt \
    stats \
    --mode raw-data \
    latest | tee -a $LOG_FILE
}

showMessage "" "-------------------->8--------------------"
showMessage "Start: " "$(date '+%Y-%m-%d %H:%M:%S')"
showMessage "Repository: " "$1"
showMessage "Working dir: " "$2"

checkDirs "$1" "$2"

checkRepo "$1"
showSnapshots "$1"
cleanUp "$1"
checkRepo "$1"
createSnashot "$1" "$2"
checkRepo "$1"
showSnapshots "$1"
showStats "$1"

showMessage "End: " "$(date '+%Y-%m-%d %H:%M:%S')"
