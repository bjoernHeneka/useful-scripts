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
        shift
        ;;
        -g|--group)
        GROUP_NAME="$2"
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

aws ${PROFILE} cognito-idp list-users  --user-pool-id ${USER_POOL_ID} --limit 60 > tmp.json



USERS=`cat tmp.json | grep Username | awk -F: '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g'`
TOKEN=`cat tmp.json | grep PaginationToken | awk -F: '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g'`

while [[ ! "x$USERS" = "x" ]]; do
  if [ ! "x$USERS" = "x" ] ; then
  	for user in $USERS; do
  		echo "Adding user ${user} to group ${GROUP_NAME}"
  		aws ${PROFILE} cognito-idp admin-add-user-to-group --user-pool-id ${USER_POOL_ID} --username ${user} --group-name ${GROUP_NAME}
  		if [ $? == 0 ]; then
  		    echo "[SUCCESS] User ${user} added to group ${GROUP_NAME}"
  		else
  		    echo "[ERROR] User ${user} could not be added to group ${GROUP_NAME}"
  		fi
  	done

    aws ${PROFILE} cognito-idp list-users  --user-pool-id ${USER_POOL_ID} --pagination-token ${TOKEN} --limit 60 > tmp2.json
    USERS=`cat tmp2.json | grep Username | awk -F: '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g'`
    TOKEN=`cat tmp2.json | grep PaginationToken | awk -F: '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//g'`

  else
  	echo "Done, no more users"
  fi
done
