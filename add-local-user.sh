#!/bin/env bash
#
# This script creates a new user on the local system
# You will be prompted to enter the username (login), the person name, and the initial password
# The new account forces password change on first login

if [[ "$(id -u)" != 0 ]]; then
    echo "Please run with sudo or as root"
    exit 1
fi

read -p "Enter the username to create: " USER_NAME
read -p "Enter the name of the person or application that will be using this account: " COMMENT
read -s -p "Enter the initial password for the account: " PASSWORD

useradd --comment "$COMMENT" --create-home "$USER_NAME"
if [[ "$?" -ne 0 ]]; then
    echo "Cannot create account"
    exit 1
fi

echo "$PASSWORD" | passwd --stdin "$USER_NAME"
if [[ "$?" -ne 0 ]]; then
    echo "Cannot set password for account"
    exit 1
fi

passwd --expire "$USER_NAME"

cat << _EOF_

User Successfully Created:
* Username: ${USER_NAME}
* Full Name: ${COMMENT}
* Hostname: ${HOSTNAME}

_EOF_

exit 0
