AWS docker infrastructure provisioning.

1. Download [Terraform](http://www.terraform.io/downloads.html), choose MacOX 64 version.
1. Install in your home bin directory:
    ```
    mkdir -p ~/bin/terraform
    cd ~/bin/terraform
    curl -L -O https://dl.bintray.com/mitchellh/terraform/terraform_0.6.0_darwin_amd64.zip
    unzip terraform_0.6.0_darwin_amd64.zip
    ```

1. Clone the repo    
    ```
    git@github.com:xuwang/aws-terraform.git
    ```
4. Install AWS CLI

    ```
    sudo easy_install pip
    sudo pip install --upgrade awscli
    ```

5. Configure AWS
    ```
    aws configure --profile mylab
    ```
6. Source scripts/alias.sh && alias

  This will create aliases for some rerequently used terraform commands, with default variable files (key.tfvars, for instance).

7. Create mylab/tfcommon/keys.tfvars

	```
    aws_access_key = "<key_id>"
    aws_secret_key = "<key_secret>"
    ```
8. Create VPC first

  This step creates VPC, subnets, and security groups. Review the vpc-net.tf and then:
    ```
    cd mylab/vpc
    tfp
    tfa
    ```
  Generate ../tfcommon/network.tfvars based on the output of the above steps. The network.vars will be used by other resouces:
  
  ```
  ./gen-network-tfvars.sh
  ```

9. Go to each AWS resource directory to create desired resource:
    ```
    tfp --var-files=../tfcommon/keys.tfvars 
    ```
 If the plan looks good:

	```
    tfa
	```
		
10. Destroy resource:
    ```
    tfpd
    tfd
    ```
