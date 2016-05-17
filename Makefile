###################
## Customization ##
###################
# Profile/Cluster name
AWS_PROFILE := coreos-cluster
CLUSTER_NAME := coreos-cluster
# To prevent you mistakenly using a wrong account (and end up destroying live environment),
# a list of allowed AWS account IDs should be defined:
#ALLOWED_ACCOUNT_IDS := "123456789012","012345678901"

# For get-vars.sh
COREOS_UPDATE_CHANNEL=beta
VM_TYPE=hvm
# For route53.tf
PRIVATE_DOMAIN=$(CLUSTER_NAME).local

# For gen-vpc-subnet-modules-tf.sh
VPC_SUBNET_MODULES=etcd,admiral,worker,elb,rds

# Supported Subnet AWS availability zones
# Update these values according to the zones available to your AWS account
AZ_US_EAST_1=us-east-1b,us-east-1c,us-east-1d,us-east-1e
AZ_US_WEST_1=us-west-1a,us-west-1b
AZ_US_WEST_2=us-west-2a,us-west-2b,us-west-2c
AZ_EU_WEST_1=eu-west-1a,eu-west-1b,eu-west-1c
AZ_EU_CETNRAL_1=eu-central-1a,eu-central-1b
AZ_AP_SOUTHEAST_1=ap-southeast-1a,ap-southeast-1b
AZ_AP_SOUTHEAST_2=ap-southeast-2a,ap-southeast-2b,ap-southeast-2c
AZ_AP_NORTHEAST_1=ap-northeast-1a,ap-northeast-1c
AZ_AP_NORTHEAST_2=ap-northeast-2a,ap-northeast-2c
AZ_SA_EAST_1=sa-east-1a,sa-east-1b,sa-east-1c

# Working Directories
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)scripts
MODULES := $(ROOT_DIR)modules
RESOURCES := $(ROOT_DIR)resources
TF_RESOURCES := $(ROOT_DIR)resources/terraforms
BUILD := $(ROOT_DIR)build
CONFIG := $(BUILD)/cloud-config
CERTS := $(BUILD)/certs
SITE_CERT := $(CERTS)/site.pem
POLICIES := $(BUILD)/policies
MODULE_VARS=$(BUILD)/module_vars.tf
VPC_MODULE=$(MODULES)/vpc

# Terraform files
TF_PORVIDER := $(BUILD)/provider.tf
TF_DESTROY_PLAN := $(BUILD)/destroy.tfplan
TF_APPLY_PLAN := $(BUILD)/destroy.tfplan
TF_STATE := $(BUILD)/terraform.tfstate

# Terraform commands
TF_GET := terraform get -update
TF_SHOW := terraform show -module-depth=1
TF_GRAPH := terraform graph -draw-cycles -verbose
TF_PLAN := terraform plan -module-depth=1
TF_APPLY := terraform apply
TF_REFRESH := terraform refresh
TF_DESTROY := terraform destroy -force
##########################
## End of customization ##
##########################

export

all: worker

help:
	@echo "Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )"
	@echo "Available resources: vpc s3 route53 iam efs elb etcd worker dockerhub admiral rds"
	@echo "For example: make plan_worker # to show what resources are planned for worker"

destroy:
	@echo "Usage: make destroy_<resource>"
	@echo "For example: make destroy_worker"
	@echo "Node: destroy may fail because of outstanding dependences"

destroy_all: \
	destroy_admiral \
	destroy_dockerhub \
	destroy_gocd \
	destroy_elk \
	destroy_worker \
	destroy_etcd \
	destroy_efs \
	destroy_elb \
	destroy_rds \
	destroy_iam \
	destroy_route53 \
	destroy_s3 \
	destroy_vpc

clean_all: destroy_all
	rm -f $(BUILD)/*.tf
	#rm -f $(BUILD)/terraform.tfstate

# TODO: Push/Pull terraform states from a tf state repo
pull_tf_state:
	@mkdir -p $(BUILD)
	@echo pull terraform state from ....

push_tf_state:
	@echo push terraform state to ....

# Load all resouces makefile
include resources/makefiles/*.mk

.PHONY: all destroy destroy_all clean_all help pull_tf_state push_tf_state
