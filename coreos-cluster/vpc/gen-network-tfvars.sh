#!/bin/bash

TFCOMMON="../tfcommon"

RESOURCES="
security_group_admiral
security_group_dockerhub
security_group_elb
security_group_etcd
security_group_worker
security_group_rds
subnet_etcd-us-west-2a
subnet_etcd-us-west-2b
subnet_etcd-us-west-2c
subnet_elb-us-west-2a
subnet_elb-us-west-2b
subnet_elb-us-west-2c
subnet_rds-us-west-2a
subnet_rds-us-west-2b
subnet_rds-us-west-2c
subnet_admiral-us-west-2a
subnet_admiral-us-west-2b
subnet_admiral-us-west-2c
subnet_worker-us-west-2a
subnet_worker-us-west-2b
subnet_worker-us-west-2c
vpc_cidr
vpc_id"

NETWORKTFVARS="${TFCOMMON}/network.tfvars"
install -v /dev/null $NETWORKTFVARS
for i in $RESOURCES
do
  echo -n "$i=" >> $NETWORKTFVARS
  echo $i
  terraform output $i >> $NETWORKTFVARS
done
