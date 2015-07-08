#!/bin/bash
#
# Init variables and sanity checks
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export TF_VAR_aws_access_key=$($DIR/read_cfg.sh $HOME/.aws/credentials coreos-cluster aws_access_key_id)
export TF_VAR_aws_secret_key=$($DIR/read_cfg.sh $HOME/.aws/credentials coreos-cluster aws_secret_access_key)
export TF_VAR_aws_region=$($DIR/read_cfg.sh $HOME/.aws/config "profile coreos-cluster" region)