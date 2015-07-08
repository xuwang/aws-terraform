## AWS CoreOS cluster provisioning with [Terraform](http://www.terraform.io/downloads.html)

1. Install [Terraform](http://www.terraform.io/downloads.html)

    For MacOS,
    ```
    brew update
    brew install terraform
    ```
    or
    ```
    mkdir -p ~/bin/terraform
    cd ~/bin/terraform
    curl -L -O https://dl.bintray.com/mitchellh/terraform/terraform_0.6.0_darwin_amd64.zip
    unzip terraform_0.6.0_darwin_amd64.zip
    ```

1. Install AWS CLI
    ```
    brew install awscli
    ```
    or

    ```
    sudo easy_install pip
    sudo pip install --upgrade awscli
    ```

1. Clone the repo    
    ```
    git clone git@github.com:xuwang/aws-terraform.git
    cd aws-terraform
    ```
1. Setup AWS Credentials at [AWS Console](https://console.aws.amazon.com/)
    1. Create a group `coreos-cluster` with `AaminstratorAccess` policy.
    2. Create an user `coreos-cluster` and download user credentials.
    3. Add user `coreos-cluster` to group `coreos-cluster`.

1. Configure AWS profile with `coreos-cluster` credentials
    ```
    aws configure --profile coreos-cluster
    ```

1. Setup Shell Alisas
    ```
    source scripts/alias.sh && alias
    ```
  This will create aliases for some rerequently used terraform commands, with default variable files (key.tfvars, for instance). For example:
    ```
   alias tfp='tf plan --var-file=../tfcommon/network.tfvars'
   alias tfa='tf apply --var-file=../tfcommon/network.tfvars'
    ```

1. Setup AWS credintials for Terraform
    ```
    source scripts/setup-tf-vars.sh
    ```
    This script will setup AWS credential enveriment variables from aws profile `coreos-cluster`
    ```
    TF_VAR_aws_access_key_id
    TF_VAR_aws_secret_access_key
    TF_VAR_aws_region
    ```

1. Create VPC first

  This step creates VPC, subnets, and security groups. Review the vpc-net.tf and then:
    ```
    cd vpc
    tfp
    tfa
    ```
  Generate ../tfcommon/network.tfvars based on the output of the above steps. The network.vars will be used by other resouces:
  
  ```
  ./gen-network-tfvars.sh
  ```

1. Go to each AWS resource directory to create desired resource:
    ```
    tfp 
    ```
 If the plan looks good:

	```
    tfa
	```
		
1. Destroy resource:
    ```
    tfpd
    tfd
    ```
