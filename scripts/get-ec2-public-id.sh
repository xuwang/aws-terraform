#!/usr/bin/env bash

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
AWS_REGION=${AWS_REGION:-us-west-2}
ASG=${1:-etcd}

EC2_IDS=$(aws --profile $AWS_PROFILE --region $AWS_REGION autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG \
    | jq .AutoScalingGroups[0].Instances[].InstanceId | xargs)

aws --profile $AWS_PROFILE --region $AWS_REGION ec2 describe-instances --instance-ids $EC2_IDS \
    | jq -r '.Reservations[].Instances | map(.NetworkInterfaces[].Association.PublicIp)[]'
