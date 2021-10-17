#!/usr/bin/env bash
set -e

HOST_FILE="/etc/hosts"
IP_ADDRESS=${*:-$(a=$(ip a show dev eth0 | grep "inet " | awk '{print $2}' && echo ${a%/*}) && echo ${a%/*})}

function iplookup() {
    file=$1
    ip=$2

    while read line
    do

        #VARIABLES
        file1=$line
        mip=$(echo $file1 | awk '{print $1}')
        name=$(echo $file1 | awk '{print $2}')


        if [ "$mip" = "$ip" ]
            then
            echo $name
        fi

    done < $file
}

for ip in $IP_ADDRESS; do
#    echo "Looking up $ip in $HOST_FILE"
    iplookup $HOST_FILE $ip
done
