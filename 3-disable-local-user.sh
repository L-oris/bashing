#!/bin/env bash

# This script disables an account

ARCHIVE_DIRECTORY='/user-archives'

usage(){
    echo "Usage: $(basename $0) [OPTIONS..] USER_NAME" >&2
    exit 1
}

create_archive_directory(){
    mkdir "$ARCHIVE_DIRECTORY" >/dev/null 2>&1
    if [[ "$?" != 0 ]]; then
        echo "Cannot create archive directory at: $ARCHIVE_DIRECTORY" >&2
        exit 1
    fi
    echo "Created archive directory at: $ARCHIVE_DIRECTORY"
}

archive_home_directory(){
    local user="$1"
    if [[ user = '' ]]; then usage; fi

    local user_home_directory="/home/${user}"
    local archive_filename="${ARCHIVE_DIRECTORY}/${user}.tar.gz"

    tar -czf "$archive_filename" "$user_home_directory"
    if [[ "$?" != 0 ]]; then
        echo "Cannot create archive for user: $user" >&2
        exit 1
    fi

    echo "Archived home directory at $archive_filename"
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

if [ ! -d "$ARCHIVE_DIRECTORY" ]; then
    create_archive_directory
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

