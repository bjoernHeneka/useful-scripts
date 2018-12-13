#!/usr/bin/env bash

POSITIONAL=()
while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -p|--profile)
        PROFILE="--profile=$2"
        shift
        shift
        ;;
        -r|--retention)
        RETENTION_DAYS="$2"
        shift
        shift
        ;;
        *)    # unknown option
        echo "Examle usage: ./updateExpire.sh -r 30"
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$RETENTION_DAYS" -gt 0 ] ; then
    for group in $(aws ${PROFILE} logs describe-log-groups --query 'logGroups[*].logGroupName' --output text); do
        echo SET Retention to ${RETENTION_DAYS} for Log Group: ${group}
        aws ${PROFILE} logs put-retention-policy --log-group-name ${group} --retention-in-days ${RETENTION_DAYS}
    done
else
    echo "Retention must be greater then 0"
fi

