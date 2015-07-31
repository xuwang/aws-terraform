<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [AWS CoreOS cluster provisioning with [Terraform](http://www.terraform.io/downloads.html)](#aws-coreos-cluster-provisioning-with-terraformhttpwwwterraformiodownloadshtml)
  - [Install Tools and Setup AWS credentials](#install-tools-and-setup-aws-credentials)
  - [Quick Start](#quick-start)
    - [To build:](#to-build)
    - [Build multi-nodes cluster](#build-multi-nodes-cluster)
    - [To destroy:](#to-destroy)
  - [Create Individual Platform Resources](#create-individual-platform-resources)
    - [To build:](#to-build-1)
    - [To destroy:](#to-destroy-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# AWS CoreOS cluster provisioning with [Terraform](http://www.terraform.io/downloads.html)

This is a practical implementation of [CoreOS cluster achirtecture] (https://coreos.com/os/docs/latest/cluster-architectures.html) built on AWS. The cluster follows CoreOS production cluster model that contains 3-node etcd cluster in an autoscalting group, a central service node that you can run shared services such as CI, logging and monigoring, a private docker registry, and a fleet of workers to run other service containers. 

The entire infrastructure is managed by Terraform. 

AWS compoments includes: VPC, security groups, IAM, S3, ELB, Route53, Autoscaling, RDS etc. 

AWS resources are defined in Terraform resource folders. The build process will copy all resources defined in the repository to a *build* directory. The view, plan, apply, and destroy operations are performed under *build*, keepting the original Terraform files in the repo intact. The *build* directory is ignored in .gitignore so that you don't accidentally checkin sensitive data. 


**WIP**


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
    1. Create a group `coreos-cluster` with `AaminstratorAccess` policy.
    2. Create a user `coreos-cluster` and download user credentials.
    3. Add user `coreos-cluster` to group `coreos-cluster`.

1. Configure AWS profile with `coreos-cluster` credentials
    ```
    $ aws configure --profile coreos-cluster
    ```


## Quick Start

### To build:

```
$ git clone git@github.com:xuwang/aws-terraform.git
$ cd aws-terraform
$ make
... build steps info ...
... at last, shows the worker's ip:
worker public ips: 52.27.156.202
...
```

This will create a vpc, s3 buckets, iam roles and keys, a etcd node, and a worker node.

Login to the worker node:

```
$ ssh -A core@52.27.156.202

CoreOS beta (723.3.0)
core@ip-52.24.xxx.xxx ~ $ fleetctl list-machines
MACHINE     IP      METADATA
289a6ba7... 10.0.1.141  disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
320bd4ac... 10.0.5.50   disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker

```

### Build multi-nodes cluster

The number of etcd nodes and worker nodes are defined in *resource/terraform/module-etcd.tf* and *resource/terraform/module-wrker.tf*

Change the cluster_desired_capacity in the file to build multi-nodes etcd/worker cluster,
for example, change to 3:

```
    cluster_desired_capacity = 3
```

Note: etcd cluster_desired_capacity should be in odd number, e.g. 3, 5, 9

You should also change the [aws_instance_type](http://aws.amazon.com/ec2/instance-types) 
from "micro" to "medium" if heavy docker containers to be hosted the nodes:

```
    image_type = "t2.medium"
```

To build:

```
$ make all
... build steps info ...
... at last, shows the worker's ip:
worker public ips:  52.26.32.57 52.10.147.7 52.27.156.202
...
```

This will create 3 etcd nodes, and 3 worker nodes.

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
0d16eb52... 10.0.1.92   disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
d320718e... 10.0.1.185  disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
f0bea88e... 10.0.1.45   disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
0cb636ac... 10.0.5.4    disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker
4acc8d6e... 10.0.5.112  disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker
fa9f4ea7... 10.0.5.140  disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker
```

### To destroy:

```
$ make destroy_all
```

This will destroy ALL resources created by 

## Create Individual Platform Resources

```
$ make help

Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )
Available resources: vpc s3 route53 iam etcd worker
For example: make worker
```

Currently defined resources:
  
Resource | Description
--- | ---
*vpc* | VPC, Subnets, and Security Groups
*s3* | S3 buckets
*iam* | Setup a deployment user and deployment keys
*route53* | Setup public and private hosted zones on Route53 DNS service
*etcd* | Setup ETCD2 cluster
*worker* | Setup application docker hosting cluster
*admiral* | TODO: Central service cluster (Jenkins, fleet-ui, monitoring, logging, etc)
*dockerhub* | TODO: Private docker registry cluster
*rds* | TODO: RDS servers

### To build:

```
$ make <resource>
```

This will create a build/<resource> directory, copy all terraform files to the build dir, 
and execute correspondent terraform cmd to build the resource on AWS.

### To destroy:

```
$ make destroy_<resource> 
```
