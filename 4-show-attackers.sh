#!/bin/env bash

LIMIT='10'
LOG_FILE="${1}"

# Make sure a file was supplied as argument
if [[ ! -e "$LOG_FILE" ]]
then 
  echo "Cannot open log file: ${LOG_FILE}" >&2
  exit 1
fi

echo 'Count,IP_Address'
cat $LOG_FILE                                  | # log_file to stdout
    grep 'Failed password'                     | # only lines containing 'Failed password'
    grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | # regex for IP Addresses
    sort | uniq -c                             | # list how many occurrencies of each linew
    while read COUNT IP_ADDRESS                  # read line by line
    do
        if [[ "$COUNT" -lt "$LIMIT" ]]; then continue; fi
        echo "${COUNT},${IP_ADDRESS}"
    done
