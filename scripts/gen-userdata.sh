#!/bin/sh -e


# Assemble cloud-config.yaml for a particular EC2 role, and upload it to S3 bucket. 
# The cloud-config.yaml fiile will be downloaded by a script when a machine is rebooted. 
# The cloud-config will be processed by coreos-cloudinit to bootstrap the machine. 

# aws profile
profile=$1

# Role to be used by the instance
role=$2

bucket=coreos-cluster-cloudinit

if [[ "X$role" = "X" ]] && [[ "X$profile" = "X" ]];
then
    echo "  Usage: $0 <profile> <role>"
    echo "Example: $0 coreos-cluster worker"
    exit 1
fi

# Upload to cloud-config location for bootstrapping
if [ -f "user-data.files" ];
then
  files=$(cat user-data.files)
  cat $files > /tmp/${role}-cloud-config.yaml
  accountId=$(aws --profile coreos-cluster iam get-user --user-name=coreos-cluster \
      | jq ".User.Arn" \
      | grep -Eo '[[:digit:]]{12}')
  if ! aws --profile $profile s3 ls s3://${accountId}-${bucket} > /dev/null 2>&1 ;
  then
     aws --profile $profile s3 mb s3://${accountId}-${bucket}
  fi
  aws --profile $profile s3 cp /tmp/${role}-cloud-config.yaml s3://${accountId}-${bucket}/$role/cloud-config.yaml
else
  echo "user-data.files doesn't exist"
  exit 1
fi
exit 0
