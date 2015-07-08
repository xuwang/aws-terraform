#!/bin/bash

config=$1
if [ -z "$config" ];
then
  echo "Need aws profile auth name."
  echo "Usage: $0: its-appsup"
  exit 1
fi

# Authenticate as this profile
awsProfile=$(./read_cfg.sh  ~/.pacific/config $config profile)

# Keys 
keys=$(./read_cfg.sh  ~/.pacific/config $config keys)

mkdir -p tmp/keypairs
for i in $keys
do
  if  aws --profile $awsProfile ec2 describe-key-pairs --key-name $i > /dev/null 2>&1 ;
  then
    echo "$i already exists."
  else
    echo "Creating $i and uploading to s3"
    aws --profile $awsProfile ec2 create-key-pair --key-name $i --query 'KeyMaterial' --output text > tmp/keypairs/$i.pem
    aws --profile $awsProfile s3 cp tmp/keypairs/$i.pem s3://${awsProfile}-config/keypairs/$i.pem
  fi
done

# Clean up
#rm -rf tmp/keypairs
