#!/bin/sh
# FSID=$(terraform output module.efs.aws-efs-file-system-efs-id)
FSID=$1
AZ=${2:-us-west-2}
sudo mkdir -p /efs
sudo mount -t nfs4 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$FSID.efs.$AZ.amazonaws.com:/ efs
