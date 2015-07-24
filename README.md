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
$ make all
... build steps info ...
... and at last should give out the worker's ip:
    EC2 public ips: 52.24.xxx.xxx
```

This will create a vpc, s3 buckets, iam roles and keys, a etcd node, and a worker node.

Login to the worker node:

```
$ ssh -A core@52.24.xxx.xxx
core@ip-52.24.xxx.xxx ~ $ fleetctl list-machines

MACHINE     IP      METADATA
289a6ba7... 10.0.1.141  disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=etcd2
320bd4ac... 10.0.5.50   disk=ssd,env=coreos-cluster,platform=ec2,provider=aws,region=us-west-2,role=worker

```

### Build multi-nodes cluster

The number of etcd nodes and worker nodes is defined in *coreos-cluster/tfcommon/override.tf*:

```
variable "etcd_cluster_capacity" {
  default = {
    min_size = 1
    max_size = 1
    desired_capacity = 1
  }
}

variable "worker_cluster_capacity" {
  default = {
    min_size = 1
    max_size = 1
    desired_capacity = 1
  }
}
```

Change the cluster_coapacity to build multi-nodes etcd/worker cluster.


### To destroy:

```
$ make destroy_all
```

This will destroy ALL resources created by 

## Create Individual Platform Resources

Currently defined resources:
  
Resource | Description
--- | ---
*vpc* | VPC, Subnets, and Security Groups
*s3* | S3 buckets
*iam* | Setup a deployment user and deployment keys
*route53* | Setup public and private hosted zones on Route53 DNS service
*etcd* | Setup ETCD2 cluster
*worker* | Setup application docker hosting cluster
*elb* | Setup predefined ELBs
*admiral* | Central service cluster (Jenkins, fleet-ui, monitoring, logging, etc)
*dockerhub* | Private docker registry cluster
*rds* | RDS servers

### To build:

```
$ make <resource>
```

or step-by-step:
```
$ make <resource> plan
$ make <resource> apply
$ make <resource> show
```

This will create a build/<resource> directory, copy all terraform files to the build dir, 
and execute correspondent terraform cmd to build the resource on AWS.

### To destroy:

```
$ make <resource> destroy
```
