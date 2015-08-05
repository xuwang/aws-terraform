#!/bin/bash

# Key name
key=${1:-coreos-cluster}

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
AWS_USER=${AWS_USER:-coreos-cluster}
CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}

TMP_DIR=keypairs

echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile ${AWS_PROFILE} iam get-user --user-name=${AWS_USER} | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
echo $AWS_ACCOUNT

if  aws --profile ${AWS_PROFILE} ec2 describe-key-pairs --key-name ${key} > /dev/null 2>&1 ;
then
    echo "keypair ${key} already exists."
else
    mkdir -p ${TMP_DIR}
    echo "Creating ${key} and uploading to s3"
    aws --profile ${AWS_PROFILE} ec2 create-key-pair --key-name ${key} --query 'KeyMaterial' --output text > ${TMP_DIR}/${key}.pem
    aws --profile ${AWS_PROFILE} s3 cp ${TMP_DIR}/${key}.pem s3://${AWS_ACCOUNT}-${CLUSTER_NAME}-config/keypairs/${key}.pem
    # copy the key to user's home .ssh
    cp ${TMP_DIR}/${key}.pem ${HOME}/.ssh; chmod 600 ${HOME}/.ssh/${key}.pem
    echo "ssh-add ${HOME}/.ssh/${key}.pem"
    ssh-add ${HOME}/.ssh/${key}.pem
    # Clean up
    # rm -rf ${TMP_DIR}
fi

