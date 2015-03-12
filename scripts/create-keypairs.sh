#!/bin/bash

# IAM user for deployment
awsProfile=$1
if [ -z "$awsProfile" ];
then
    echo "Need AWS profile."
    exit 1
fi

# For clients who use the the same aws account as $profile
if [ ! -z $2 ];
then 
    pacificProfile=$2
else 
    pacificProfile=$awsProfile
fi

# Keypairs
tmpdir='tmp/keypairs'
#  Cleanup previously created keypairs
[ -d $tmpdir ] && rm -rf $tmpdir
keys=$(./read_cfg.sh  ~/.pacific/config $pacificProfile keys)
mkdir -p tmp/keypairs
for i in $keys
do
    if  aws --profile $awsProfile s3 ls s3://${awsProfile}-config/keypairs/$i ;
    then
        echo "$i already exists."
    else
        echo "Creating $i"
        #aws --profile $awsProfile s3 rm s3://${awsProfile}-config/keypairs/$i.pem
        #aws --profile $awsProfile ec2 create-key-pair --key-name $i --query 'KeyMaterial' --output text > tmp/keypairs/$i.pem
        #aws --profile $awsProfile s3 cp tmp/keypairs s3://$awProfile}-config/keypairs --recursive
    fi
done

# Clean up
#rm -rf tmp/keypairs
