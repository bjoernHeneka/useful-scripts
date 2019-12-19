#!/usr/bin/env bash

for group in $(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --log-group-name-prefix /aws/rds --output text); do
  echo deleting ${group}
  aws logs delete-log-group --log-group-name ${group}
done
