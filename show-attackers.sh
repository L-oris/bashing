#!/bin/env bash

# Given a log file, count the number of failed logins by IP address
# Output as comma-separated values (CSV file)

# Count,IP_Address
# 6749,182.100.67.59
# 3379,183.3.202.111
# 3085,218.25.208.92
# 142,41.223.57.47
# 87,195.154.49.74
# 57,180.128.252.1

##### CONSTANTS #####

LIMIT='10'
LOG_FILE="${1}"

##### FUNCTIONS #####

usage(){
    echo "Usage: $(basename $0) LOG_FILE" >&2
    exit 1
}

##### MAIN #####

if [[ ! -e "$LOG_FILE" ]]; then 
    echo "Cannot open log file: ${LOG_FILE}" >&2
    usage
fi

echo 'Count,IP_Address'
cat $LOG_FILE                                  | # log_file to stdout
    grep 'Failed password'                     | # only lines containing 'Failed password'
    grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | # regex for IP Addresses
    sort | uniq -c                             | # list how many occurrencies of each line (each IP Address)
    sort -nr                                   | # sort occurrencies (most frequent to least frequent)
    while read COUNT IP_ADDRESS                  # read line by line
    do
        if [[ "$COUNT" -lt "$LIMIT" ]]; then 
          continue
        fi

        echo "${COUNT},${IP_ADDRESS}"
    done

exit 0