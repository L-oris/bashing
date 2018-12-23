#!/bin/env bash

##### CONSTANTS #####

SERVER_LIST='/vagrant/servers'
VERBOSE_MODE='false'
DRY_RUN='false'
EXIT_STATUS='0'

##### FUNCTIONS #####

usage(){
cat >&2 << _EOF_
Usage: $(basename $0) [-f FILE] [-dsv] COMMAND
Executes COMMAND as a single command on every server
    -f FILE  Use FILE for the list of servers. Default: ${SERVER_LIST}
    -d       Dry run mode. Display the COMMAND that would have been executed and exit
    -s       Execute the COMMAND using sudo on the remote server
    -v       Verbose mode. Displays the server name before executing COMMAND
_EOF_
exit 1
}

##### MAIN #####

if [[ "$(id -u)" = 0 ]]; then
    echo 'Do not execute this script as root; use the -s option instead' >&2
    exit 1
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
    echo "Cannot open server list file: $SERVER_LIST" >&2
    exit 1
fi

for SERVER in $(cat $SERVER_LIST); do
    if [[ "$VERBOSE_MODE" = 'true' ]]; then
        echo "Execute on server: $SERVER"
    fi

    # With 'ConnectTimeout' option, the 'ssh' command doesn't hang for more than 2 seconds if a host is down
    SSH_COMMAND="ssh -o ConnectTimeout=2 $SERVER $SUDO $COMMAND"

    if [[ "$DRY_RUN" = 'true' ]]; then
        echo "Command: $SSH_COMMAND"
        continue
    fi

    # Run SSH Command
    $SSH_COMMAND
    if [[ "$?" != 0 ]]; then
        EXIT_STATUS="$?"
        echo "Command on server: $SERVER failed with status $EXIT_STATUS" >&2
    fi
done

exit $EXIT_STATUS
