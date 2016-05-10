
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

The cluster follows CoreOS production cluster model that contains an autoscaling _etcd_ cluster, and an autoscaling _worker_ cluster for hosted containers. You can optionally add an _admiral_ cluster for shared services such as CI, private docker registry, logging and monitoring, etc.

The entire infrastructure is managed by [Terraform](https://www.terraform.io/intro/index.html).

For other type of Unix cluster, see a similar repo [aws-linux-cluster](https://github.com/xuwang/aws-linux-cluster).

## Setup AWS credentials

Go to [AWS Console](https://console.aws.amazon.com/).

1. Signup AWS account if you don't already have one. The default EC2 instances created by this tool is covered by AWS Free Tier (https://aws.amazon.com/free/) service.
2. Create a group `coreos-cluster` with `AdministratorAccess` policy.
3. Create a user `coreos-cluster` and __Download__ the user credentials.
4. Add user `coreos-cluster` to group `coreos-cluster`.

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

2. Install [Jq](http://stedolan.github.io/jq/)
    ```
    $ brew install jq
    ```

3. Install [AWS CLI](https://github.com/aws/aws-cli)
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
If you use Vagrant, instead of install tools on your host machine, there is Vagranetfile for a Ubuntu box with all the necessary tools installed:

```
$ vagrant up
$ vagrant ssh
$ cd aws-terraform
```

#### Configure AWS profile with `coreos-cluster` credentials

```
$ aws configure --profile coreos-cluster
```

Use the [downloaded aws user credentials](#setup-aws-credentials) when prompted.

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
*efs* | EFS cluster
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


# First steps

To control your cluster with fleet, you use the fleetctl command. As you can read here, fleet has no built-in security mechanism. If you want to use fleetctl from your workstation, you need to configure fleet to use an SSH tunnel. I found that an easy way to do this is to configure the SSH user and private key in ~/.ssh/config and then export the FLEETCTL_TUNNEL variable on the command line. Like so:

Host coreos
  User     core
  HostName <ip-of-a-cluster-instance>
  IdentityFile ~/.ssh/your_aws_private_key.pem

And:

export FLEETCTL_TUNNEL=<ip-of-a-cluster-instance>

It doesn’t matter which instance you use as the other end of your SSH tunnel, as long as you use the EC2 instance’s public IP address. Of course the IP address in your SSH config must be the same as what you export in the environment variable.

Also, make sure to add your private key to ssh-agent, to make sure the ssh commands work:

ssh-add ~/.ssh/your_aws_private_key.pem

Once you’ve done this, the following command:

fleetctl list-machines

Should show you the servers in your cluster:

MACHINE     IP              METADATA
015a6f3a... 10.104.242.206  -
3588db25... 10.73.200.139   -

Host coreos
  User     core
  HostName 52.36.252.184
  IdentityFile /Users/rasheed/Documents/projects/stakater/aws-terraform-xuwang/aws-terraform/build/keypairs/gocd.pem

export FLEETCTL_TUNNEL=52.36.252.184

ssh-add /Users/rasheed/Documents/projects/stakater/aws-terraform-xuwang/aws-terraform/build/keypairs/gocd.pem

# fleetctl commands

fleetctl submit hello.service
fleetctl start hello.service
fleetctl status hello.service
fleetctl destroy hello.service


To see the output of the service, call:ß

fleetctl journal hello.service


Fleet is effectively a clustered layer on top of systemd. Fleet uses systemd unit files with an (optional) added section to tell fleet which machines it should run on. There is very little magic.

list systemd units

systemctl list-units | grep fleet

systemctl restart fleet.service

# systemd

introduction to systemd: https://coreos.com/docs/launching-containers/launching/getting-started-with-systemd/

# fleet

introduction to fleet: https://coreos.com/fleet/docs/latest/launching-containers-fleet.html

# # DONT

1. Don't modify the cluster-name. If you do then please do update the "s3-cloudconfig-bootstrap.sh" as well. Specifically this path:

```
# Bucket path for the cloud-config.yaml 
bucket=${accountId}-stakater-cloudinit
```

# Troubleshooting

Two types of units can be run in your cluster — standard and global units. Standard units are long-running processes that are scheduled onto a single machine. If that machine goes offline, the unit will be migrated onto a new machine and started.

Global units will be run on all machines in the cluster.

1.  The fleet logs (sudo journalctl -u fleet) will provide more clarity on what’s going on under the hood.

2. There are two fleetctl commands to view units in the cluster: list-unit-files, which shows the units that fleet knows about and whether or not they are global, and list-units, which shows the current state of units actively loaded into machines in the cluster. 

$ fleetctl list-unit-files

You can view all of the machines in the cluster by running list-machines:

$ fleetctl list-machines

$ fleetctl list-units


Check the fleet service to see what errors it gives us:

$ systemctl status -l fleet

For each of our essential services, we should check the status and logs. The general way of doing this is:

systemctl status -l <service>
journalctl -b -u <service>


If we check the etcd logs, we will see something like this:

journalctl -b -u etcd

When your CoreOS machine processes the cloud-config file, it generates stub systemd unit files that it uses to start up fleet and etcd. To see the systemd configuration files that were created and are being used to start your services, change to the directory where they were dropped:

cd /run/systemd/system
ls -F

to list all units

systemctl


Services usually fail because of a missing dependency (e.g. a file or mount point), missing configuration, or incorrect permissions. In this example we see that the dev-mqueue unit with type mount fails. As the type is a mount, the reason is most likely because mounting a particular partition failed.

By using the systemctl status command we can see the details of the dev-mqueue.mount unit:

[root@localhost ~]# systemctl status dev-mqueue.mount

online tool to validate cloud-config

https://coreos.com/validate/

Can you check to see if the service is enabled (systemctl is-enabled etcd2)? If it's not enabled, it may be a dependency of something that is enabled. You can test with systemctl list-dependencies etcd2 --reverse

check status of a service

systemctl status -l gocd


# 

There’s a few things worth pointing out:

1. The container is clearly dependent on having Docker running, hence the Requires line. The After line is also needed to avoid race conditions.
2. Before we start the container, we first stop and remove any existing container with the same name and then pull the latest version of the image. The “-” at the start means systemd won’t abort if the command fails.
3. This means that our container will be started from scratch each time. If you want to persist data then you’ll need to do something with volumes or volume containers, or change the code to restart the old container if it exists.
4. We’ve used TimeoutStartSec=0 to turn off timeouts, as the docker pull may take a while.


# systemd unit status

You can check units status by:

$ sudo systemctl status gocd-agent-1

Or the unit logs by:

$ sudo journalctl -exu gocd-agent-1

Usually, the log info will tell what's going on.

# to see the docker logs

docker logs <IMAGE_NAME>

------------

I don't know what is SIGKILL'ing the process. Perhaps there is something in the full system journal around that time that might indicate journalctl --since "2015-03-20 08:49"? Try running dmesg too? Maybe the kernel is killing it?

-------------

Step 1: get into the coreos machine:

ssh -i /home/vagrant/aws-terraform/build/keypairs/gocd.pem core@<public-ip>

Step 2: get list of running docker containers

docker ps

Step 3: to check logs of particular container/service

journalctl -exu gocd-agent-1

or 

journalctl -exu gocd-agent-cd-prod.service

Step 4: 