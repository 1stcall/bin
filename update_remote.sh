#!/usr/bin/env bash

set -e

DEBUG=${DEBUG:-0}   # 0 = no debugging info, 
                    # >0 = show error & minimal info, 
                    # 2 = more info, 
                    # 3 = verbose info, 
                    # 4 = show debuging ip address ,
                    # 5 = bailout on error

ipList=( \
    rpi4b-1 \
    rpi4b-2 \
    rpi4b-3 \
    rpi4b-4 )

commandsToRun=( \
    "export DEBIAN_FRONTEND=noninteractive" \
    "sudo apt-get update" \
    "sudo apt-get upgrade -y" \
    "sudo apt-get autoremove -y" \
    "sudo shutdown --reboot 1 \"$(hostname) rebooting now!\" || true"  \
    "exit 0" )
    #"sudo apt-get upgrade -y --dry-run" \
    #"sudo apt-get autoremove -y --dry-run" \ 
sshCommand="ssh -t"

for ipAddress in "${ipList[@]}"
do
    [[ DEBUG -eq 4 ]] && \
        printf "D: ipaddress: %s\n" "$ipAddress" >&2
    
    runCommand="${sshCommand} ${ipAddress}"
    
    [[ DEBUG -gt 1 ]] && \
        printf "D: runCommand: %s\n" "$runCommand" >&2

    for cmd in "${commandsToRun[@]}"
    do
        [[ DEBUG -gt 2 ]] && \
            printf "D: cmd: %s\n" "$cmd" >&2
        
        runCommand="$runCommand $cmd &&"
    done

    runCommand=${runCommand:0:-3}

    [[ DEBUG -gt 0 ]] && \
        printf "D: runCommand: %s\n" "$runCommand"
    ret=0
    ${runCommand} || \
        ret=$? && \
        [[ DEBUG -gt 0 ]] && [[ ret -ne 0 ]] && \
            printf "\nE: \`%s\' returned error: %i.\n" "$runCommand" $ret >&2 && \
            [[ DEBUG -eq 5 ]] && \
                printf "E: %s\n" "Bailing out." && \
                exit $ret

done

exit 0
