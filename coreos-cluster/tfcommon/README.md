## Shared Terraform files

This directory has files shared by submodules:

* override.tf - terraform var overrides
* provider.tf - terraform provider credential vars
* variables.tf - terraform global vars
* cloud-config - directory that contains shared cloudinit segments
* assume_role_policy.json - assume role policy for ec2, shared by all ec2 instances

Some generated tfvars files also go here:

* keys.tfvars - credential key values
* vpc.tfvars - vpc and globle security var values
* route53.tfvars - aws route53 hosted zone ids