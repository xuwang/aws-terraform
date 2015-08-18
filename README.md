
# AWS CoreOS cluster provisioning with [Terraform](http://www.terraform.io/downloads.html)
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

##Table of Contents##

- [Overview](#overview)
- [Install tools and setup AWS credentials](#install-tools-and-setup-aws-credentials)
- [Quick start](#quick-start)
- [Build multi-node cluster](#build-multi-node-cluster)
- [Destroy all resources](#destroy-all-resources)
- [Manage individual platform resources](#manage-individual-platform-resources)
- [Use an existing AWS profile](#use-an-existing-aws-profile)
- [Technical notes](#technical-notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

This is a practical implementation of [CoreOS cluster architectures ] (https://coreos.com/os/docs/latest/cluster-architectures.html) built on AWS. The cluster follows CoreOS production cluster model that contains 3-node etcd cluster in an autoscalting group, a central service node that you can run shared services such as CI, logging and monitoring, a private docker registry, and a fleet of workers to run other service containers. 

The entire infrastructure is managed by Terraform. 

AWS compoments includes: VPC, security groups, IAM, S3, ELB, Route53, Autoscaling, RDS etc. 

AWS resources are defined in Terraform resource folders. The build process will copy all resources defined in the repository to a *build* directory. The view, plan, apply, and destroy operations are performed under *build*, keepting the original Terraform files in the repo intact. The *build* directory is ignored in .gitignore so that you don't accidentally checkin sensitive data. 

## Install Tools and Setup AWS credentials

1. Install [Terraform](http://www.terraform.io/downloads.html)

    For MacOS,
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

1. Install AWS CLI
    ```
    $ brew install awscli
    ```
    or

    ```
    $ sudo easy_install pip
    $ sudo pip install --upgrade awscli
    ```

1. Install [Jq](http://stedolan.github.io/jq/)
    ```
    $ brew install jq
    ```

1. Setup AWS Credentials at [AWS Console](https://console.aws.amazon.com/)
    1. Create a group `coreos-cluster` with `AdministratorAccess` policy.
    2. Create a user `coreos-cluster` and download user credentials.
    3. Add user `coreos-cluster` to group `coreos-cluster`.

1. Configure AWS profile with `coreos-cluster` credentials
    ```
    $ aws configure --profile coreos-cluster
    ```

## Quick start

This default build will create one etcd node and one worker node cluster in a VPC, with application buckets for data, necessary iam roles, polices, keypairs and keys. The nodes are t2.micro instance and run the latest CoreOS beta release.
Reources are defined under aws-terraform/resources/terraform directory. You should review and make changes there if needed. 

Clone the repo:
```
$ git clone git@github.com:xuwang/aws-terraform.git
$ cd aws-terraform
```

To build:
```
$ make
... build steps info ...
... at last, shows the worker's ip:
worker public ips: 52.27.156.202
...
```

To see the list of resources created:

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

Login to the worker node:

```
$ ssh -A core@52.27.156.202

CoreOS beta (723.3.0)
core@ip-52.27.156.202 ~ $ fleetctl list-machines
MACHINE     IP      METADATA
289a6ba7... 10.0.1.141  env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
320bd4ac... 10.0.5.50   env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker

```
## Build multi-node cluster

The number of etcd nodes and worker nodes are defined in *resource/terraform/module-etcd.tf* and *resource/terraform/module-worker.tf*

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

## Destroy all resources

```
$ make destroy_all
```
This will destroy ALL resources created by this project.

## Manage individual platform resources

You can create individual resources and the automated-scripts will create resources automatically based on dependencies. 
```
$ make help

Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )
Available resources: vpc s3 route53 iam etcd worker
For example: make worker
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

To build the cluster step by step by step:

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

### Use an existing AWS profile
AWS profile, user, and cluster name are defined at the top of  _Makefile_:

```
# Profile/Cluster name
AWS_PROFILE := coreos-cluster
AWS_USER := coreos-cluster
CLUSTER_NAME := coreos-cluster
```
These can be changed to match your AWS profile and cluster name.

## Technical notes
* Makefiles define resource dependencies and use scripts to generate necessart Terraform 
variables and configurations. 
This provides stream-lined build automation. 
* Etcd forms cluster by self-discovery through its autoscaling group. 
A initial-cluster file is upload to s3://ACCOUNT-NUMBER-coreos-cluster-cloundinit bucket.
* Worker nodes run in etcd proxy mode and download initial-cluster file from the s3 bucket 
and join the cluster at boot time. 
* All nodes use a common bootstrap shell script as user-data, which downloads initial-cluster file 
and nodes specific cloud-config.yaml to configure the node. If cloud-config changes, 
no need to rebuild an instance.
Just reboot it to pick up the change.
* CoreOS AMI is generated on the fly to keep it up-to-data.
*Terraform auto-generated launch configuration name and CBD feature is used 
to allow change of launch configuration on a live autoscaling group, e.g. ami id, image type, cluster size, etc.
However, exisiting ec2 instances in the autoscaling group has to be recycled to pick up new LC, e.g. 
terminate instance to let AWS create a new instance.
* Although etcd cluster is on an autoscaling group but it should be set with
a fixed, odd number cluster_desired_capacity=min_size=max_size.
Etcd cluster size could be dynamically increased but it should **never be decreased** on a live system.

