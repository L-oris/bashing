#!/bin/env bash

# This script disables an account

usage(){
    echo "Usage: $(basename $0) [OPTIONS..] USER_NAME" >&2
    exit 1
}

archive_home_directory(){
    local user="$1"
    if [[ user = '' ]]; then usage; fi

    echo "Archived home directory for user $user"
}

delete_user(){
    local user="$1"
    local remove_home_directory="$2"
    if [[ user = '' ]]; then usage; fi

    echo "Deleted user $user"
}

disable_user(){
    local user="$1"
    if [[ user = '' ]]; then usage; fi

    echo "Disabled user $user"
}

if [[ $(id -u) != 0 ]]; then
    echo 'Please run with sudo or as root' >&2
    exit 1
fi

while getopts ard OPTION; do
    case $OPTION in
        a) ARCHIVE_HOME_DIRECTORY='true' ;;
        r) REMOVE_HOME_DIRECTORY='-r' ;;
        d) DELETE_USER='true' ;;
        ?) usage ;;
    esac
done

# Remove options processed by 'getopts'
shift "$(( OPTIND - 1 ))"


if [[ "$#" < 1 ]]; then
    usage
fi

for USER_NAME in "$@"; do
    echo "Processing user: $USER_NAME"

    if ! id "$USER_NAME" >/dev/null 2>&1; then
        echo 'User not found' >&2
        exit 1
    fi

    USER_ID="$(id -u $USER_NAME)"
    if [[ "$USER_ID" < 1000 ]]; then
        echo "Cannot process user $USER_NAME with UID ${USER_ID}: system account" >&2
        exit 1
    fi

    if [[ "$ARCHIVE_HOME_DIRECTORY" = 'true' ]]; then
        archive_home_directory $USER_NAME
    fi

    if [[ "$DELETE_USER" = 'true' ]]; then
        delete_user $USER_NAME $REMOVE_HOME_DIRECTORY
    else
        disable_user $USER_NAME
    fi
done

exit 0

