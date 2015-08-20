#!/usr/bin/env bash

# Replace AWS-ACCOUNT with aws account number in *.tf and *.json files. Can be used 
# to form policy documents, resource names etc, with the aws account number as part of a string.

# AWS account number - getting it from an existing user resource
# 
AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}

echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')

files=$(grep -s -l AWS-ACCOUNT -r $@)
if [ "X$files" != "X" ];
then
  for f in $files
  do
    perl -p -i -e "s/AWS-ACCOUNT/$AWS_ACCOUNT/g" $f
  done
fi

