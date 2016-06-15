#!/usr/bin/env bash

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}
AWS_ACCOUNTID=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
BUCKET="${AWS_ACCOUNTID}-${CLUSTER_NAME}-cloudinit"
KEY="etcd/initial-cluster"
if ! aws --profile $AWS_PROFILE s3api wait object-exists --bucket ${BUCKET} --key ${KEY};
then
  echo "${BUCKET}/initial-cluster doesn't exist"
  exit 1
fi
exit 0
