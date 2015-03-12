#!/bin/bash

RESOURCES="
security_group_bastion
security_group_docker-ext-elb
security_group_etcd
security_group_hosting
security_group_rds
subnet_ext_elb-us-west-2a
subnet_ext_elb-us-west-2b
subnet_ext_elb-us-west-2c
subnet_rds-us-west-2a
subnet_rds-us-west-2b
subnet_rds-us-west-2c
subnet_core-us-west-2a
subnet_core-us-west-2b
subnet_core-us-west-2c
subnet_bastion-us-west-2a
subnet_bastion-us-west-2b
subnet_bastion-us-west-2c
subnet_etcd-a-us-west-2a
subnet_etcd-b-us-west-2b
subnet_etcd-c-us-west-2c
subnet_hosting-us-west-2a
subnet_hosting-us-west-2b
subnet_hosting-us-west-2c
vpc_cidr
vpc_id"

NETWORKTFVARS="${TFCOMMON}/network.tfvars"
install -v /dev/null $NETWORKTFVARS
for i in $RESOURCES
do
  echo -n "$i=" >> $NETWORKTFVARS
  echo $i
  terraform -module-depth=-1 --var-file=${TFCOMMON}/network.tf output $i >> $NETWORKTFVARS
done
