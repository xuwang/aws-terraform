# AWS CoreOS cluster provisioning with [Terraform](http://www.terraform.io/downloads.html)

This is a practical implementation of [CoreOS cluster achirtecture] (https://coreos.com/os/docs/latest/cluster-architectures.html) built on AWS. The cluster follows CoreOS production cluster model that contains 3-node etcd cluster in an autoscalting group, a central service node that you can run shared services such as CI, logging and monigoring, a private docker registry, and a fleet of workers to run other service containers. 

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

1. Clone the repo    
    ```
    $ git clone git@github.com:xuwang/aws-terraform.git
    $ cd aws-terraform
    ```
1. Setup AWS Credentials at [AWS Console](https://console.aws.amazon.com/)
    1. Create a group `coreos-cluster` with `AaminstratorAccess` policy.
    2. Create a user `coreos-cluster` and download user credentials.
    3. Add user `coreos-cluster` to group `coreos-cluster`.

1. Configure AWS profile with `coreos-cluster` credentials
    ```
    $ aws configure --profile coreos-cluster
    ```


## Create VPC, Subnets, and Security Groups

1. To build:

    ```
    $ make vpc
    ```

    or step-by-step:

    ```
    $ make vpc plan
    $ make vpc apply
    $ make vpc show
    ```

    This will create a build/vpc directory, copy terraform files from coreos-cluster to the build dir, 
    and execute correspondent terraform cmd to build vpc on AWS.


1. To destroy:

    ```
    $ make vpc destroy
    ```

    Note: Destroy other resources before destroy vpc. Otherwise, destroy will fail because of dependencies.

## Create Other Platform Resources

Currently defined resources are:

  - s3
  - iam
  - route53
  - etcd
  - central-services (Jenkins, fleet-ui, monitoring, splunk)
  - dockerhub
  - worker
  - rds
  - elb

1. To build:

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

2. To destroy:

    ```
    $ make <resource> destroy
    ```
