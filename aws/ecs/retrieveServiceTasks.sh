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
        -c|--cluster)
        CLUSTER="--cluster=$2"
        shift
        shift
        ;;
        -s|--service)
        SERVICE="--service=$2"
        shift
        shift
        ;;
        *)    # unknown option
        echo "Examle usage: ./retrieveServiceTasks.sh.sh -r 30"
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


aws ${PROFILE} ecs describe-tasks ${CLUSTER} --tasks $(aws ${PROFILE} ecs list-tasks ${CLUSTER} ${SERVICE} --query 'taskArns[*]' --output text)
