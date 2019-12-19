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
        -t|--table)
        TABLE="$2"
        shift
        shift
        ;;
        *)    # unknown option
        echo "Examle usage: ./addUsersToGroup.sh.sh -u eu-central-1_XXXXX -p example -g my-group"
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


export KEY_SCHEMA="$(aws ${PROFILE} dynamodb describe-table \
    --table-name ${TABLE} | \
    jq -r '.Table.KeySchema[].AttributeName' | \
    tr '\n' ' ')"


aws ${PROFILE} dynamodb scan \
   --table-name ${TABLE} \
   --attributes-to-get ${KEY_SCHEMA} | \
   jq -r ".Items[] | tojson" | \
   tr '\n' '\0' | \
   xargs -0 -I keyItem \
    aws dynamodb delete-item \
      --table-name ${TABLE} \
      --key=keyItem
