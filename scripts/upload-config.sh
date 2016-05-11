#!/bin/sh -e

AWS_PROFILE=${AWS_PROFILE}
CLUSTER_NAME=${CLUSTER_NAME}

echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
echo $AWS_ACCOUNT

CONFIG_BUCKET=${CONFIG_BUCKET:-${CLUSTER_NAME}-config}
BUCKET_URL="s3://${AWS_ACCOUNT}-${CONFIG_BUCKET}"

# Role to be used by the instance
AWS_ROLE=$1

# TODO: this should be able to accept any array of config files!
# A config file to upload
CONFIG_FILE=$2

# Extract the file name
fname=`basename $CONFIG_FILE`

echo $AWS_ROLE
echo $CONFIG_FILE

aws --profile ${AWS_PROFILE} s3 cp ${CONFIG_FILE} ${BUCKET_URL}/${AWS_ROLE}/${fname}
