#!/bin/bash

trustpolicy='../data/ec2-role-trust-policy.json'
[ -z "$1" ] && echo "profile name is required. E.g. ./update-profile.sh jenkins" && exit 1 || profile=$1
[ ! -f $trustpolicy ]  && echo "$trustpolicy is required." && exit 1
policydoc="../data/s3-${profile}-policy.json"
[ ! -f $policydoc ]  && echo "$policydoc is required." && exit 1

aws --profile anchorage iam put-role-policy --role-name $profile  --policy-name ${profile} --policy-document file://$policydoc
#aws --profile anchorage iam put-user-policy --user-name $profile  --policy-name ${profile} --policy-document file://$policydoc
