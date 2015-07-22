#!/bin/sh -e


# Assemble cloud-config.yaml for a particular EC2 role, and upload it to S3 bucket. The cloud-config.yaml fiile will be downloaded
# by a script when a machine is rebooted. The cloud-config will be processed by coreos-cloudinit to bootstrap the machine. 

# A directory under git@git.itlab.stanford.edu:et/pacific-aws.git checkout, e.g. anchorage, itlab.
project=$1

# Role to be used by the instance
role=$2

# Script dir
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ "X$role" = "X" ]] && [[ "X$project" = "X" ]];
then
    echo "  Usage: $0 <project> <role>"
    echo "Example: $0 itlab hosting"
    exit 1
elif [ ! -d $DIR/../$project/$role ];
then
    echo "$DIR/../$project/$role doesn't exist. Need to checkout the repo?"
    exit 1
fi

# Upload to cloud-config location for bootstrapping
cd $DIR/../$project/$role 
if [ -f "user-data.files" ];
then
  files=$(cat user-data.files)
  cat $files > /tmp/$role-cloud-config.yaml
  accountId=$(aws --profile $project iam get-role --role-name=$role | grep -Eo '[[:digit:]]{12}')
  if ! aws --profile $project s3 ls s3://$accountId-cloud-config > /dev/null 2>&1 ;
  then
     aws --profile $project s3 mb s3://$accountId-cloud-config
  fi
  aws --profile $project s3 cp /tmp/$role-cloud-config.yaml s3://$accountId-cloud-config/$role/cloud-config.yaml
else
  echo "user-data.files doesn't exist"
  exit 1
fi
exit 0
