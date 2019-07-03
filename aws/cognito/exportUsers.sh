#!/usr/bin/env bash

POSITIONAL=()
while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -u|--user-pool-id)
        USER_POOL_ID="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--profile)
        PROFILE="--profile=$2"
        shift
        ;;
        *)    # unknown option
        echo "Examle usage: ./deleteAllUsers.sh -u eu-central-1_XXXXX -p example"
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

RUN=1
until [ $RUN -eq 0 ] ; do
echo "Listing users"
USERS=`aws ${PROFILE} cognito-idp list-users  --user-pool-id ${USER_POOL_ID} | grep Username | awk -F: '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g'`
if [ ! "x$USERS" = "x" ] ; then
	for user in $USERS; do
		echo "user ${user}"
		if [ $? == 0 ]; then
		    echo "[SUCCESS] User ${user} deleted"
		else
		    echo "[ERROR] User ${user} could not been deleted"
		fi
	done
else
	echo "Done, no more users"
	RUN=0
fi
done
