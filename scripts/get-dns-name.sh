#!/usr/bin/env bash

elb_name=${1:-''}
if [ -z "$elb_name" ]; then
  echo "Need load balancer name."
  exit 1
fi

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
AWS_REGION=${AWS_REGION:-us-west-2}

elb_dnsname=$(aws elb describe-load-balancers --profile $AWS_PROFILE --load-balancer-names=$elb_name | \
	jq -r '.LoadBalancerDescriptions[].DNSName')

echo $elb_dnsname
