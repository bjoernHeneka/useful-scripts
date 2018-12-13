#!/usr/bin/env bash

function initAndGetSignedUrl {
aws ${1} cognito-idp create-user-import-job \
  --job-name ${2} \
  --user-pool-id ${3} \
  --cloud-watch-logs-role-arn "${4}" \
  --query 'UserImportJob.PreSignedUrl'  \
  --output text
}

JOBNAME="myGreatImportJob"

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
        -n|--name)
        JOBNAME="$2"
        shift
        shift
        ;;
        -r|--role)
        ROLE_ARN="$2"
        shift
        shift
        ;;
        -f|--file)
        FILEPATH="$2"
        shift
        shift
        ;;
        *)    # unknown option
        echo "Examle usage: ./importUsers.sh -u eu-central-1_XXXXX -p example"
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

SIGNED_URL=$(initAndGetSignedUrl ${PROFILE} ${JOBNAME} ${USER_POOL_ID} ${ROLE_ARN})

# @TODO Get the real job id we created initially
JOBID=$(aws ${PROFILE} cognito-idp list-user-import-jobs --user-pool-id "${USER_POOL_ID}" --max-results 1 --query 'UserImportJobs[0].JobId' --output text)

# Upload the file
# @TODO Ensure file exists
curl -v -T "${FILEPATH}" -H "x-amz-server-side-encryption:aws:kms" "${SIGNED_URL}"

# Start the import
aws ${PROFILE} cognito-idp start-user-import-job --user-pool-id "${USER_POOL_ID}" --job-id "${JOBID}"

