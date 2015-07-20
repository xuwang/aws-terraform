#!/usr/bin/env bash

# Replace AWS-ACCOUNT with aws account number in *.tf and *.json files. Can be used 
# to form policy documents, resource names etc, with the aws account number as part of a string.

# AWS account number - getting it from an existing user resource
echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile coreos-cluster iam get-user --user-name=coreos-cluster | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')

files=$(grep -s -l AWS-ACCOUNT -r  *.tf  *.json)
if [ "X$files" != "X" ];
then
  for f in $files
  do
    perl -p -i -e "s/AWS-ACCOUNT/$AWS_ACCOUNT/g" $f
  done
fi

