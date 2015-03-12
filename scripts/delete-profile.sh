#!/bin/bash

[ -z "$1" ] && echo "profile name is required. E.g. ./update-profile.sh jenkins" && exit 1 || profile=$1
policydoc="../data/s3-${profile}-policy.json"
[ ! -f $policydoc ]  && echo "$policydoc is required." && exit 1

aws --profile anchorage iam remove-role-from-instance-profile  --instance-profile-name=$profile --role-name=$profile
aws --profile anchorage iam delete-instance-profile --instance-profile-name=$profile
aws --profile anchorage iam  delete-role-policy --role-name=$profile --policy-name=s3-${profile}
aws --profile anchorage iam delete-role --role-name=$profile
