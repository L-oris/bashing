#!/bin/env bash

##### CONSTANTS #####

SERVER_LIST='/vagrant/servers'
VERBOSE_MODE='false'
DRY_RUN='false'
EXIT_STATUS=0

##### FUNCTIONS #####

usage(){
    echo 'Usage: something' >&2
    exit 1
}

##### MAIN #####

if [[ "$(id -u)" = 0 ]]; then
    echo 'Please do not run command as super user; use -s option instead' >&2
    usage
fi

while getopts f:dsv OPTION; do
    case $OPTION in
        f) SERVER_LIST="$OPTARG" ;;
        d) DRY_RUN='true' ;;
        s) SUDO='sudo' ;;
        v) VERBOSE_MODE='true' ;;
        ?) usage ;;
    esac
done

# Remove options processed by 'getopts'
shift "$(( OPTIND - 1 ))"

if [[ "$#" -lt 1 ]]; then
    usage
fi

COMMAND="$@"

if [[ ! -e "$SERVER_LIST" ]]; then
    echo 'Invalid server list provided' >&2
    exit 1
fi

for SERVER in $(cat $SERVER_LIST); do
    if [[ "$VERBOSE" = 'true' ]]; then
        echo "Server: $SERVER"
    fi

    SSH_COMMAND="ssh -o ConnectTimeout=2 $SERVER $SUDO $COMMAND"
    if [[ "$DRY_RUN" = 'true' ]]; then
        echo "Command: $SSH_COMMAND"
        continue
    fi

    # Run SSH Command
    $SSH_COMMAND
    if [[ "$?" != 0 ]]; then
        EXIT_STATUS="$?"
        echo "Command exited with status $EXIT_STATUS on server: $SERVER" >&2
    fi
done

exit EXIT_STATUS
