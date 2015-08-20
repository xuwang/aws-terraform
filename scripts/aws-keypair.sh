#!/bin/bash

# Default key name
key='coreos-cluster'

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}

echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
echo $AWS_ACCOUNT

TMP_DIR=keypairs

create(){
  if  aws --profile ${AWS_PROFILE} ec2 describe-key-pairs --key-name ${key} > /dev/null 2>&1 ;
  then
    echo "keypair ${key} already exists."
  else
    mkdir -p ${TMP_DIR}
    chmod 700 ${TMP_DIR}
    echo "Creating keypair ${key} and uploading to s3"
    aws --profile ${AWS_PROFILE} ec2 create-key-pair --key-name ${key} --query 'KeyMaterial' --output text > ${TMP_DIR}/${key}.pem
    aws --profile ${AWS_PROFILE} s3 cp ${TMP_DIR}/${key}.pem s3://${AWS_ACCOUNT}-${CLUSTER_NAME}-config/keypairs/${key}.pem
    # copy the key to user's home .ssh
    # cp ${TMP_DIR}/${key}.pem ${HOME}/.ssh; chmod 600 ${HOME}/.ssh/${key}.pem
    chmod 600 ${TMP_DIR}/${key}.pem
    echo "ssh-add ${TMP_DIR}/${key}.pem"
    ssh-add ${TMP_DIR}/${key}.pem
    # Clean up
    # rm -rf ${TMP_DIR}
  fi
}

destroy(){
  if  ! aws --profile ${AWS_PROFILE} ec2 describe-key-pairs --key-name ${key} > /dev/null 2>&1 ;
  then
    echo "keypair ${key} does not exists."
  else
    if [ -f ${TMP_DIR}/${key}.pem ];
    then
      echo "Remove from ssh agent"
      ssh-add -L |grep "${TMP_DIR}/${key}.pem" > ${TMP_DIR}/${key}.pub
      [ -s ${TMP_DIR}/${key}.pub ] && ssh-add -d ${TMP_DIR}/${key}.pub
      aws --profile ${AWS_PROFILE} s3 rm s3://${AWS_ACCOUNT}-${CLUSTER_NAME}-config/keypairs/${key}.pem
      echo "Delete aws keypair ${key}"
      aws --profile ${AWS_PROFILE} ec2 delete-key-pair --key-name ${key}  
      echo "Revmove from ${TMP_DIR}"
      rm -rf ${TMP_DIR}/${key}.pem
      rm -rf ${TMP_DIR}/${key}.pub
    fi
  fi 
}

while getopts ":c:d:h" OPTION
do
  key=$OPTARG
  case $OPTION in
    c)
      create
      ;;
    d)
      destroy
      ;;
    *)
      echo "Usage: $(basename $0) -c|-d keyname"
      exit 1
      ;;
  esac
done
exit 0
