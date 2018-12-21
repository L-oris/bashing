#!/bin/env bash

##### CONSTANTS #####

SERVER_LIST='/vagrant/servers'
VERBOSE_MODE='false'

##### FUNCTIONS #####

usage(){
    echo 'Usage: something' >&2
    exit 1
}

##### MAIN #####

while getopts f:nsv OPTION; do
    case $OPTION in
        f)
            SERVER_LIST="$OPTARG"
            echo "Provided file $SERVER_LIST"
            ;;
        n) echo 'dry_run' ;;
        s) echo 'run_as_sudo' ;;
        v) 
            VERBOSE_MODE='true'
            echo 'Verbose mode ON'
            ;;
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
    echo "Run command: $COMMAND on server $SERVER"
done

exit 0
