AWS docker infrastructure provisioning.

1. Download [Terraform](http://www.terraform.io/downloads.html), choose MacOX 64 version.
2. Install in your home bin directory:

		mkdir -p ~/bin/terraform
		cd ~/bin/terraform
		curl -L -O https://dl.bintray.com/mitchellh/terraform/terraform_0.3.7_darwin_amd64.zip
		unzip terraform_0.3.7_darwin_amd64.zip

3. Checkout
 
		git@github.com:xuwang/aws-terraform.git


4. Install AWS CLI

		sudo easy_install pip
		sudo pip install --upgrade awscli

5. Configure AWS

		aws configure --profile mylab

6. 	Source scripts/alias.sh && alias

7. Create keys.tfvars under tfcommon with AWS key and secrect

8. Go to each AWS resource directory and:

        tfp --var-files=keys.tfvars 
		

  If the plan looks good:

        tfa
		
9. To destroy resource:

        tfpd --var-files=keys.tfvars
		tfd
