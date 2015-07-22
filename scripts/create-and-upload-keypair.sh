#!/bin/bash

# Key name
key=${1:-coreos-cluster}

# Authenticate as this profile
awsProfile=${2:-coreos-cluster}

echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile ${awsProfile} iam get-user --user-name=coreos-cluster | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')

mkdir -p keypairs
if  aws --profile $awsProfile ec2 describe-key-pairs --key-name ${key} > /dev/null 2>&1 ;
then
  echo "${key} already exists."
else
  echo "Creating ${key} and uploading to s3"
  aws --profile $awsProfile ec2 create-key-pair --key-name ${key} --query 'KeyMaterial' --output text > keypairs/${key}.pem
  aws --profile $awsProfile s3 cp keypairs/${key}.pem s3://${AWS_ACCOUNT}-coreos-cluster-config/keypairs/${key}.pem
  # copy the key to user's home .ssh
  cp keypairs/${key}.pem ${HOME}/.ssh; chmod 600 ${HOME}/.ssh/${key}.pem
  ssh-add ${HOME}/.ssh/${key}.pem
fi

# Clean up
rm -rf keypairs
