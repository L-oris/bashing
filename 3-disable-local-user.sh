#!/bin/env bash

# This script disables an account

usage(){
    echo "Usage: $(basename $0) USER_NAME" >&2
    exit 1
}

if [[ $(id -u) != '0' ]]; then
    echo 'Please run as root or super user' >&2
    usage
fi

while getopts adr OPTION; do
    case $OPTION in
        a) ARCHIVE_HOME_DIRECTORY='true' ;;
        d) REMOVE_HOME_DIRECTORY='true' ;;
        d) DELETE_USER='true' ;;
        ?) usage ;;
    esac
done

# Shift options
shift "$(( OPTIND - 1 ))"

if [[ "$REMOVE_HOME_DIRECTORY" = 1 && "$DELETE_ACCOUNT" != '1' ]]; then
    echo 'Cannot remove home directory without deleting the account' >&2
    usage
fi


if [[ "$#" = 0 ]]; then
    echo 'Please provide a list of users!' >&2
    usage
fi

while [[ "$1" != '' ]]; do
    USER_NAME=$1
    shift

    if ! id $USER_NAME >/dev/null 2>&1; then
        echo "User $USER_NAME does not exist" >&2
        usage
    fi

    if [[ "$(id -u $USER_NAME)" < 1000 ]]; then
        echo 'Cannot change system accounts' >&2
        usage
    fi

    if [[ "$DELETE_ACCOUNT" != 1 ]]; then
        disable_account $USER_NAME
        exit 0
    
    if [[ "$CREATE_HOME_DIRECTORY_ARCHIVE" = 1 ]]; then
        create_home_archive $USER_NAME
        exit 0
    fi

    if [[ "$REMOVE_HOME_DIRECTORY" = 1 ]]; then
        remove_home_archive_and_delete $USER_NAME
    else 
        create_home_archive $USER_NAME
    fi
done

exit 0

# chage -E 0 

