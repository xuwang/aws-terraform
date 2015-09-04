
# AWS CoreOS cluster provisioning with [Terraform](https://www.terraform.io/intro/index.html)
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

## Table of Contents##

- [Overview](#overview)
- [Setup AWS credentials](#setup-aws-credentials)
- [Install tools](#install-tools)
- [Quick start](#quick-start)
- [Customization](#customization)
- [Build multi-node cluster](#build-multi-node-cluster)
- [Manage individual platform resources](#manage-individual-platform-resources)
- [Technical notes](#technical-notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

This is a practical implementation of [CoreOS cluster architectures ] 
(https://coreos.com/os/docs/latest/cluster-architectures.html) built on AWS.
The cluster follows CoreOS production cluster model that contains an autoscaling _etcd_ cluster, 
and an autoscaling _worker_ cluster for hosted containers. You can optionally add an _admiral_ cluster for
shared services such as CI, private docker registry, logging and monitoring, etc.

The entire infrastructure is managed by [Terraform](https://www.terraform.io/intro/index.html).

For other type of Unix cluster, see a similar repo [aws-linux-cluster](https://github.com/xuwang/aws-linux-cluster).

## Setup AWS credentials

Go to [AWS Console](https://console.aws.amazon.com/).

1. Signup AWS account if you don't already have one. The default EC2 instances created by this tool is covered by AWS Free Tier (https://aws.amazon.com/free/) service.
1. Create a group `coreos-cluster` with `AdministratorAccess` policy.
1. Create a user `coreos-cluster` and __Download__ the user credentials.
1. Add user `coreos-cluster` to group `coreos-cluster`.

## Install tools

If you use [Vagrant](https://www.vagrantup.com/), you can skip this section and go to 
[Quick Start](#quick-start) section.

Instructions for install tools on MacOS:

1. Install [Terraform](http://www.terraform.io/downloads.html)

    ```
    $ brew update
    $ brew install terraform
    ```
    or
    ```
    $ mkdir -p ~/bin/terraform
    $ cd ~/bin/terraform
    $ curl -L -O https://dl.bintray.com/mitchellh/terraform/terraform_0.6.0_darwin_amd64.zip
    $ unzip terraform_0.6.0_darwin_amd64.zip
    ```

1. Install [Jq](http://stedolan.github.io/jq/)
    ```
    $ brew install jq
    ```

1. Install [AWS CLI](https://github.com/aws/aws-cli)
    ```
    $ brew install awscli
    ```
    or

    ```
    $ sudo easy_install pip
    $ sudo pip install --upgrade awscli
    ```

For other platforms, follow the tool links and instructions on tool sites.

## Quick start

#### Clone the repo:
```
$ git clone https://github.com/xuwang/aws-terraform.git
$ cd aws-terraform
```

#### Run Vagrant ubuntu box with terraform installed (Optional)
If you use Vagrant, instead of install tools on your host machine,
there is Vagranetfile for a Ubuntu box with all the necessary tools installed:
```
$ vagrant up
$ vagrant ssh
$ cd aws-terraform
```

#### Configure AWS profile with `coreos-cluster` credentials

```
$ aws configure --profile coreos-cluster
```
Use the [downloaded aws user credentials](#setup-aws-credentials)
when prompted.

The above command will create a __coreos-cluster__ profile authentication section in ~/.aws/config and ~/.aws/credentials files. The build process bellow will automatically configure Terraform AWS provider credentials using this profile. 

#### To build:

This default build will create one etcd node and one worker node cluster in a VPC, 
with application buckets for data, necessary iam roles, polices, keypairs and keys. 
The instance type for the nodes is t2.micro. You can review the configuration and 
make changes if needed. See [Customization](#customization) for details.

```
$ make
... build steps info ...
... at last, shows the worker's ip:
worker public ips: 52.27.156.202
...
```

#### To see the list of resources created:

```
$ make show
...
  module.etcd.aws_autoscaling_group.etcd:
  id = etcd
  availability_zones.# = 3
  availability_zones.2050015877 = us-west-2c
  availability_zones.221770259 = us-west-2b
  availability_zones.2487133097 = us-west-2a
  default_cooldown = 300
  desired_capacity = 1
  force_delete = true
  health_check_grace_period = 0
  health_check_type = EC2
  launch_configuration = terraform-4wjntqyn7rbfld5qa4qj6s3tie
  load_balancers.# = 0
  max_size = 9
  min_size = 1
  name = etcd
  tag.# = 1
....
```

#### Login to the worker node:

```
$ ssh -A core@52.27.156.202

CoreOS beta (723.3.0)
core@ip-52.27.156.202 ~ $ fleetctl list-machines
MACHINE     IP      METADATA
289a6ba7... 10.0.1.141  env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
320bd4ac... 10.0.5.50   env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker

```

#### Destroy all resources

```
$ make destroy_all
```
This will destroy ALL resources created by this project.

## Customization

* The default values for VPC, ec2 instance profile, policies, keys, autoscaling group, lanuch configurations etc., 
can be override in resources/terraform/module-<resource>.tf` files.

* AWS profile and cluster name are defined at the top of  _Makefile_:

  ```
  AWS_PROFILE := coreos-cluster
  CLUSTER_NAME := coreos-cluster
  ```
  
  These can also be customized to match your AWS profile and cluster name.


## Build multi-node cluster

The number of etcd nodes and worker nodes are defined in *resource/terraform/module-etcd.tf* 
and *resource/terraform/module-worker.tf*

Change the cluster_desired_capacity in the file to build multi-nodes etcd/worker cluster,
for example, change to 3:

```
    cluster_desired_capacity = 3
```

Note: etcd minimum, maximum and cluster_desired_capacity should be the same and in odd number, e.g. 3, 5, 9

You should also change the [aws_instance_type](http://aws.amazon.com/ec2/instance-types) 
from `micro` to `medium` or `large` if heavy docker containers to be hosted on the nodes:

```
    image_type = "t2.medium"
    root_volume_size =  12
    docker_volume_size =  120
```

To build:
```
$ make all
... build steps info ...
... at last, shows the worker's ip:
worker public ips:  52.26.32.57 52.10.147.7 52.27.156.202
...
```

Login to a worker node:

```
$ ssh -A core@52.27.156.202
CoreOS beta (723.3.0)

core@ip-52.27.156.202 ~ $ etcdctl cluster-health
cluster is healthy
member 34d5239c565aa4f6 is healthy
member 5d6f4a5f10a44465 is healthy
member ab930e93b1d5946c is healthy

core@ip-10-0-1-92 ~ $ etcdctl member list
34d5239c565aa4f6: name=i-65e333ac peerURLs=http://10.0.1.92:2380 clientURLs=http://10.0.1.92:2379
5d6f4a5f10a44465: name=i-cd40d405 peerURLs=http://10.0.1.185:2380 clientURLs=http://10.0.1.185:2379
ab930e93b1d5946c: name=i-ecfa0d1a peerURLs=http://10.0.1.45:2380 clientURLs=http://10.0.1.45:2379

core@ip-52.27.156.202 ~ $ fleetctl list-machines
MACHINE     IP      METADATA
0d16eb52... 10.0.1.92   env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
d320718e... 10.0.1.185  env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
f0bea88e... 10.0.1.45   env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
0cb636ac... 10.0.5.4    env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker
4acc8d6e... 10.0.5.112  env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker
fa9f4ea7... 10.0.5.140  env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker
```

## Manage individual platform resources

You can create individual resources and the automated-scripts will create resources automatically based on dependencies. 
```
$ make help

Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )
Available resources: vpc s3 route53 iam etcd worker
For example: make worker # to show what resources are planned for worker
```

Currently defined resources:
  
Resource | Description
--- | ---
*vpc* | VPC, gateway, and subnets
*s3* | S3 buckets
*iam* | Setup a deployment user and deployment keys
*route53* | Setup public and private hosted zones on Route53 DNS service
*elb* | Setup application ELBs
*etcd* | Setup ETCD2 cluster
*worker* | Setup application docker hosting cluster
*admiral* | Central service cluster (Jenkins, fleet-ui, monitoring, logging, etc)
*dockerhub* | Private docker registry cluster
*rds* | RDS servers
*cloudtrail* | Setup AWS CloudTrail

To build the cluster step by step:

```
$ make init
$ make vpc
$ make etcd
$ make worker
```

Make commands can be re-run. If a resource already exists, it just refreshes the terraform status.

This will create a build/<resource> directory, copy all terraform files to the build dir, 
and execute correspondent terraform cmd to build the resource on AWS.

To destroy a resource:

```
$ make destroy_<resource> 
```

## Technical notes
* Etcd cluster is on an autoscaling group. It should be set with a fixed, odd number (1,3,5..), and cluster_desired_capacity=min_size=max_size.
* Cluster discovery is managed with [dockerage/etcd-aws-cluster](https://hub.docker.com/r/dockerage/etcd-aws-cluster/) image. etcd cluster is formed by self-discover through its auto-scaling group and then an etcd initial cluster is updated automatically to s3://AWS-ACCOUNT-CLUSTER-NAME-cloudinit/etcd/initial-cluster s3 bucket. Worker nodes join the cluster by downloading the etcd initial-cluster file from the s3 bucket during their bootstrap.
* AWS resources are defined in resources and modules directories.
The build process will copy all resource files from _resources_ to a _build_ directory. 
The terraform actions are performed under _build_, which is ignored in .gitignore. The original Terraform files in the repo are kept intact. 
* Makefiles and shell scripts are used to give us more flexibility on tasks Terraform 
leftover. This provides stream-lined build automation. 
* All nodes use a common bootstrap shell script as user-data, which downloads initial-cluster file 
and nodes specific cloud-config.yaml to configure the node. If cloud-config changes, 
no need to rebuild an instance. Just reboot it to pick up the change.
* CoreOS AMI is generated on the fly to keep it up-to-data. Default channel can be changed in Makefile.
* Terraform auto-generated launch configuration name and CBD feature are used 
to allow launch configuration update on a live autoscaling group, 
however, running ec2 instances in the autoscaling group has to be recycled outside of the Terraform management to pick up the new LC.
* For a production system, the security groups defined in etcd, worker, and admiral module 
should be carefully reviewed and tightened.

