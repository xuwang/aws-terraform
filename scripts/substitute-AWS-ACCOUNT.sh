#!/usr/bin/env bash

# Replace AWS-ACCOUNT with aws account number in *.tf and *.json files. Can be used 
# to form policy documents, resource names etc, with the aws account number as part of string.
# A backup of the original file will be created.

# Script location
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# AWS account number - getting it from an existing user resource
AWS_ACCOUNT=$(aws --profile coreos-cluster iam get-user --user-name=coreos-cluster | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
cd ${DIR}/../coreos-cluster
files=$(grep -s -l AWS-ACCOUNT -r --include *.tf --include *.json .)
for i in $files
do
  echo "perl -pi.bak -e "s/AWS-ACCOUNT/$AWS_ACCOUNT/g" $i" 
done

