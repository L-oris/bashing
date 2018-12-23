#!/bin/env bash
#
# This script creates a new user on the local system
# You must supply a username as an argument to the script
# The remaining arguments will be treated as the full name for the account
# An initial password will be automatically generated for the account
# The new account forces password change on first login

if [[ "$(id -u)" != 0 ]]; then
    echo 'Please run with sudo or as root' >&2
    exit 1
fi

if [[ "$#" -lt 1 ]]; then 
    echo "Usage: $(basename $0) USER_NAME [COMMENT]..." >&2
    echo 'Create an account on the local system with the name of USER_NAME and a comments field of COMMENT' >&2
    exit 1
fi

# The first parameter is the user name
USER_NAME=$1
# The rest of the parameters are for the account comments
shift
COMMENT="$@"

PASSWORD=$(date +%s%N${RANDOM} | sha256sum | head -c48)

useradd --comment "$COMMENT" --create-home "$USER_NAME" &> /dev/null
if [[ "$?" -ne 0 ]]; then
    echo 'Cannot create account' >&2
    exit 1
fi

echo "$PASSWORD" | passwd --stdin "$USER_NAME" &> /dev/null
if [[ "$?" -ne 0 ]]; then
    echo 'Cannot set password for account' >&2
    exit 1
fi

passwd --expire "$USER_NAME" &> /dev/null

cat << _EOF_
User successfully created:
* Username: $USER_NAME
* Full Name: $COMMENT
* Password: $PASSWORD
* Hostname: $HOSTNAME
_EOF_

exit 0
