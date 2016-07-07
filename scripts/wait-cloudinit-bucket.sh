#!/usr/bin/env bash

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}
AWS_ACCOUNTID=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
BUCKET="${AWS_ACCOUNTID}-${CLUSTER_NAME}-cloudinit"
KEY="etcd/initial-cluster"
retry=2
ready=0
until [[ $retry -eq 0 ]]  || [[ $ready -eq 1  ]]
do
	if aws --profile $AWS_PROFILE s3api wait object-exists --bucket ${BUCKET} --key ${KEY};
	then
		ready=1
	else
		let "retry--"
	fi
done
[[ $ready -eq 1 ]] && exit 0 || echo "${BUCKET}/initial-cluster doesn't exist" && exit 1
