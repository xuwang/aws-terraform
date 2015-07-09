#!/usr/bin/env bash

AWS_ACCOUNT=$(aws --profile coreos-cluster iam get-user --user-name=coreos-cluster | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')

cd ..
perl -pi -e "s/AWS-ACCOUNT/$AWS_ACCOUNT/g" */*.tf */*.json

