#!/usr/bin/env bash

REGION=${2:-us-west-2}
PROFILE=${3:-coreos-cluster}
ASG=${1:-etcd}

EC2_IDS=$(aws --profile $PROFILE autoscaling describe-auto-scaling-groups \
        --region $REGION --auto-scaling-group-name $ASG \
    | jq .AutoScalingGroups[0].Instances[].InstanceId | xargs)

aws --profile $PROFILE ec2 describe-instances --region $REGION --instance-ids $EC2_IDS \
    | jq -r '.Reservations[].Instances | map(.NetworkInterfaces[].Association.PublicIp)[]'
