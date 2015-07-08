#!/bin/bash
#
# Init variables and sanity checks
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TF_VAR_aws_access_key=$($DIR/read_cfg.sh $HOME/.aws/credentials coreos-cluster aws_access_key_id)
TF_VAR_aws_secret_key=$($DIR/read_cfg.sh $HOME/.aws/credentials coreos-cluster aws_secret_access_key)
TF_VAR_aws_region=$($DIR/read_cfg.sh $HOME/.aws/config "profile coreos-cluster" region)

cat > $DIR/../coreos-cluster/tfcommon/keys.tfvars <<EOF
aws_access_key = "$TF_VAR_aws_access_key"
aws_secret_key = "$TF_VAR_aws_secret_key"
aws_region = "$TF_VAR_aws_region"
EOF