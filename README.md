
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

Other two Terrraform implmentation references are:
* A Unix cluster with an AMI of your choice:  see a similar repo [aws-linux-cluster](https://github.com/xuwang/aws-linux-cluster).
* A static website using hugo and AWS Lambda: see [terraform-hugo-lambda](https://github.com/xuwang/terraform-hugo-lambda).

## Setup AWS credentials

Go to [AWS Console](https://console.aws.amazon.com/).

1. Signup AWS account if you don't already have one. The default EC2 instances created by this tool is covered by AWS Free Tier (https://aws.amazon.com/free/) service.
1. Create a group `coreos-cluster` with `AdministratorAccess` policy.
1. Create a user `coreos-cluster` and __Download__ the user credentials.
1. Add user `coreos-cluster` to group `coreos-cluster`.

Of course you can change the group and user name to your specific implementation.

## Install tools

If you use [Vagrant](https://www.vagrantup.com/), you can skip this section and go to 
[Quick Start](#quick-start) section.

Instructions for install tools requried on MacOS:

Install [Terraform](http://www.terraform.io/downloads.html), [Jq](http://stedolan.github.io/jq/), [graphviz](http://www.graphviz.org/), [AWS CLI](https://github.com/aws/aws-cli):

    ```
    $ brew update
    $ brew install terraform jq graphviz awscli
    ```

For other platforms, follow the tool links and instructions on these tools's site. Remeber to peirodically update these packages. 

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

#### To build with 'cluster-manager.sh' script

__cluster-manager.sh__ is a wrapper script around make for most commmon operations. The commands are safe to run and re-run, because 
Terraform will keep status and pick up from where it left should something fail.
```
$ ./cluster-manager.sh
```
#### To build using make command

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

The code will try to add keypairs to the ssh-agent on your laptop, so if you run `ssh-add -l`, you should see the keypairs. You can also find them in *build/keypairs* directory, and in `s3://<aws-account>-<cluster-name>-config/keypairs`. When you destroy the
cluster, these will be removed too.  The build directory and *.pem, *.key are all ignored in .gitignore. 

Now you shouild be able to login:
```
$ ssh core@52.27.156.202
```

Although the above quick start will help to understand what the code will do, the common development work flow is to build in steps, for example, you will build VPC first, then etcd, then worker. This is what I usually do for a new environment:

```
make plan_vpc
make vpc
make plan_etcd
make etcd
make plan_worker
make worker
```

#### To see the list of resources created

```
$ make show_all | more -R
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

#### Login to cluster node:


In addition to the key paris that you will find in build/keypairs directory, by default ssh port 22 is open to your local machine IP. You should be able to login. 

```
etcd public ips:  50.112.218.23
xuwang@~/projects/aws-terraform $ ssh core@50.112.218.23
CoreOS beta (1068.3.0)
Last login: Thu Jul  7 03:58:22 2016 from 108.84.154.184
core@ip-10-10-1-60 ~ $ fleetctl list-machines
MACHINE   IP    METADATA
5c2f6436... 10.10.1.60  env=coreos-cluster,platform=ec2,provider=aws,role=etcd2
75440a64... 10.10.5.156 env=coreos-cluster,platform=ec2,provider=aws,role=worker
77a52b6b... 10.10.5.123 env=coreos-cluster,platform=ec2,provider=aws,role=worker

```

You can always get etcd public ips or worker ips by running:

```
$ make get_etcd_ips
$ make get_worker_ips
```

#### Destroy all resources

```
$ make destroy_all
```
This will destroy ALL resources created by this project. You will be asked to confirm before proceed.

## Customization

* The default values for VPC, ec2 instance profile, policies, keys, autoscaling group, lanuch configurations etc., 
can be override in resources/terraform/<resource>/<resource>.tf` files.

* Default values defined at the top of _Makefile_:

```
AWS_PROFILE ?= coreos-cluster
CLUSTER_NAME ?= coreos-cluster
APP_REPOSITORY ?= https://github.com/dockerage/coreos-cluster-apps
COREOS_UPDATE_CHANNE ?= beta
AWS_REGION ?= us-west-2
VM_TYPE ?= hvm
```
  
These can be changed to match your AWS implementation, or the easist way is to create an envs.sh file to override some
of these values, so you don't need to chnge Makefile:

```
export AWS_PROFILE=my-dev-cluster
export CLUSTER_NAME=my-dev-cluser
export COREOS_UPDATE_CHANNE=stable
```

Then run
```
$ source ./envs.sh
```

## Build multi-node cluster

The number of etcd nodes and worker nodes are defined in *resource/terraform/etcd.tf* 
and *resource/terraform/worker.tf*

Change the cluster_desired_capacity in the file to build multi-nodes etcd/worker cluster,
for example, change to 3:

```
    cluster_desired_capacity = 3
```

Note: etcd minimum, maximum and cluster_desired_capacity should be the same and in odd number, e.g. 1, 3, 5, 9.

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
*efs* | EFS cluster. Need to enable EFS preview in your AWS account.
*etcd* | Setup ETCD2 cluster
*worker* | Setup application docker hosting cluster
*admiral* | (Optional) Service cluster (Jenkins, fleet-ui, monitoring...). You can run these on worker machine, but you might have a different cluster for different access roles.
*rds* | (Optional) RDS server (postgres and mysql)
*cloudtrail* | Setup AWS CloudTrail

To build the cluster step by step:

```
$ make init
$ make plan_vpc
$ make vpc
$ make plan_etcd
$ make etcd
$ make plan_worker
$ make worker
```

To destroy:

```
make plan_destroy_all
make destroy_all
```

Make commands can be re-run. If a resource already exists, it just refreshes the terraform status.

This will create a build/<resource> directory, copy all terraform files to the build dir, 
and execute correspondent terraform cmd to build the resource on AWS.

To destroy a resource:

```
$ make plan_destroy_<resource>
$ make destroy_<resource> 
```

## Technical notes
* File tree
```
$ tree -I build
.
├── CHANGELOG.md
├── LICENSE
├── Makefile
├── README.md
├── Vagrantfile
├── app-deploy-key.pem.yaml.sample
├── cluster-manager.sh
├── envs.sh
├── envs.sh.sample
├── graph-examples
│   ├── admiral.png
│   ├── efs.png
│   ├── elb-ci.png
│   ├── etcd.png
│   ├── iam.png
│   ├── rds.png
│   ├── route53.png
│   ├── s3.png
│   ├── vpc.png
│   └── worker.png
├── modules
│   ├── cluster
│   │   ├── cluster.tf
│   │   └── variables.tf
│   ├── efs-target
│   │   └── efs-target.tf
│   └── subnet
│       └── subnet.tf
├── resources
│   ├── certs
│   │   ├── Makefile
│   │   ├── README.md
│   │   ├── etcd-client.cnf
│   │   ├── etcd.cnf
│   │   ├── rootCA.cnf
│   │   └── site.cnf
│   ├── cloud-config
│   │   ├── admiral.yaml.tmpl
│   │   ├── dockerhub.yaml
│   │   ├── etcd.yaml.tmpl
│   │   ├── files.yaml
│   │   ├── s3-cloudconfig-bootstrap.sh
│   │   ├── systemd-units-flannel.yaml
│   │   ├── systemd-units.yaml
│   │   └── worker.yaml.tmpl
│   ├── makefiles
│   │   ├── admiral.mk
│   │   ├── cloudtrail.mk
│   │   ├── efs.mk
│   │   ├── elb-ci.mk
│   │   ├── etcd.mk
│   │   ├── iam.mk
│   │   ├── init.mk
│   │   ├── rds.mk
│   │   ├── route53.mk
│   │   ├── s3.mk
│   │   ├── vpc.mk
│   │   └── worker.mk
│   ├── policies
│   │   ├── admiral_policy.json
│   │   ├── assume_role_policy.json
│   │   ├── deployment_policy.json
│   │   ├── dockerhub_policy.json
│   │   ├── etcd_policy.json
│   │   └── worker_policy.json
│   └── terraforms
│       ├── admiral
│       │   └── admiral.tf
│       ├── efs
│       │   └── efs.tf
│       ├── elb-ci
│       │   └── ci.tf
│       ├── elb-dockerhub
│       │   └── dockerhub.tf
│       ├── etcd
│       │   └── etcd.tf
│       ├── iam
│       │   └── iam.tf
│       ├── rds
│       │   ├── mysql.tf
│       │   ├── postgres.tf
│       │   └── security-group.tf
│       ├── route53
│       │   └── route53.tf
│       ├── s3
│       │   └── s3.tf
│       ├── vpc
│       │   ├── vpc-subnet-admiral.tf
│       │   ├── vpc-subnet-elb.tf
│       │   ├── vpc-subnet-etcd.tf
│       │   ├── vpc-subnet-rds.tf
│       │   ├── vpc-subnet-worker.tf
│       │   └── vpc.tf
│       └── worker
│           └── worker.tf
└── scripts
    ├── aws-keypair.sh
    ├── cloudtrail-admin.sh
    ├── gen-provider.sh
    ├── gen-rds-password.sh
    ├── gen-tf-vars.sh
    ├── get-ami.sh
    ├── get-dns-name.sh
    ├── get-ec2-public-id.sh
    ├── get-vpc-id.sh
    ├── session-lock.sh
    ├── substitute-AWS-ACCOUNT.sh
    ├── substitute-CLUSTER-NAME.sh
    └── tf-apply-confirm.sh

```
* Etcd cluster is on its own autoscaling group. It should be set with a fixed, odd number (1,3,5..), and cluster_desired_capacity=min_size=max_size.
* Cluster discovery is managed with [dockerage/etcd-aws-cluster](https://hub.docker.com/r/dockerage/etcd-aws-cluster/) image. etcd cluster is formed by self-discovery through its auto-scaling group and then an etcd initial cluster is updated automatically to s3://AWS-ACCOUNT-CLUSTER-NAME-cloudinit/etcd/initial-cluster s3 bucket. Worker nodes join the cluster by downloading the etcd initial-cluster file from the s3 bucket during their bootstrap.
* AWS resources are defined in resources and modules directories.
The build process will copy all resource files from _resources_ to a _build_ directory. 
The Terraform actions are performed under _build_, which is ignored in .gitignore. Tfstat file will also be stored in _build_ directory. The original Terraform files in the repo are kept intact. 
* Makefiles and shell scripts are used to give more flexibility to fill the gap between Terraform and AWS API. This provides stream-lined build automation. 
* All nodes use one common bootstrap script *resources/cloud-config/s3-cloudconfig-bootstrap.sh* as _user-data_ which downloads initial-cluster file and the cluster nodes's specific cloud-config.yaml to configure a node. If cloud-config changes, no need to rebuild an instance. Just reboot it to pick up the change.
* CoreOS AMI is generated on the fly to keep it up-to-data. Default channel can be changed in Makefile.
* Terraform auto-generated launch configuration name and CBD feature are used 
to allow launch configuration update on a live autoscaling group, 
however, running ec2 instances in the autoscaling group has to be recycled outside of the Terraform management to pick up the new LC.
* For a production system, the security groups defined in etcd, worker, and admiral module 
should be carefully reviewed and tightened.
* Databases (mysql and posgres) are created are public accessible for the purpose of testing and ports are open to `allow_ssh_cidr` variable, which is your local machine IP by default.  You can should change the security-group.tf, mysql.tf, and postgres.tf under `resources/terraform/rds` directory do adjust. 
The password is generated on the fly. Both password and database address/endpoints can be retrived by `make show_rds`. A public DNS name is also created, e.g. mysqldb.example.com, postgresdb.example.com. The domain name is configured by APP_DOMAIN variable in envs.sh file.
* Cluster CoreOS upgrade: workers and etcd clusters are defined as separate locksmith group so they can be independently managed by locksmith. The locksmith group, reboot stragtegy (best-effort) and upgrade window are defined under _resources/cloud_config_ directory.

