# useful-scripts
My personal collection of useful scripts

Prerquisites:
- package jq is required for some commands

## AWS

### EC2
- Show all instances within an account
Usage:
```bash
./aws/ec2/show-all-instances.sh
```

### Cloudwatch
- Set all coudwatch logs to specific retention date
Usage:
```bash
./aws/cloudwatch/updateExpire.sh -r 30 -p my-great-profile-name
```

### Cognito
- Delete all users of a cognito user pool
Usage:
```bash
./aws/cognito/deleteAllUsers.sh -p my-great-profile-name -u eu-centra-1_424242
```

- Add all users to a specific group
```bash
./aws/cognito/addUsersToGroup.sh.sh -p my-great-profile-name -u eu-centra-1_424242 -g my-group
```

- Import users from CSV
```bash
./aws/cognito/importUsers.sh \
    -p my-great-profile-name \
    -u eu-centra-1_424242 \
    -f /path/to/file.csv \
    -r arn:aws:iam::123456789:role/service-role/Cognito-Import-Role
```
