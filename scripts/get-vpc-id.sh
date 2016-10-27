#!/usr/bin/env bash
# Check if the cluster already exists. 
# Only proceed if the cluster doesn't exist. Return value is 0.

CLUSTER_NAME=${CLUSTER_NAME:-''}
AWS_PROFILE=${AWS_PROFILE:-''}
if [ ! -z "$CLUSTER_NAME" ]; then
  cluster_tag=$(aws --profile ${AWS_PROFILE} ec2 describe-vpcs  --filters "Name=tag:Name,Values=${CLUSTER_NAME}" | jq -r '.Vpcs[0].VpcId')
  if [[ $? -ne 0 ]]; then
    echo "Error checking cluster."
    exit 1
  elif [[ $cluster_tag  =~ "vpc-" ]]; then
    echo "Cluster ${CLUSTER_NAME} exists with vpc id $cluster_tag"
  else
    echo "Cluster ${CLUSTER_NAME} does not exists."
  fi
else
  echo "Cluster name is required."   
  exit 1
fi
exit 0
