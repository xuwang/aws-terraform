# Profile/Cluster name
AWS_PROFILE := coreos-cluster
AWS_USER := coreos-cluster

# Working Directories
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)scripts
MODULES := $(ROOT_DIR)modules
RESOURCES := $(ROOT_DIR)resources
TF_RESOURCES := $(ROOT_DIR)resources/terraforms
BUILD := $(ROOT_DIR)build
CONFIG := $(BUILD)/cloud-config
CERTS := $(BUILD)/certs
POLICIES := $(BUILD)/policies

# Terraform files
TF_PORVIDER := $(BUILD)/provider.tf
TF_DESTROY_PLAN := $(BUILD)/destroy.tfplan
TF_APPLY_PLAN := $(BUILD)/destroy.tfplan

# Terraform commands
TF_GET := terraform get -update
TF_SHOW := terraform show
TF_GRAPH := terraform graph -draw-cycles -verbose
TF_PLAN := terraform plan
TF_APPLY := terraform apply
TF_REFRESH := terraform refresh
TF_DESTROY := terraform destroy -force

# For get-ami.sh
COREOS_UPDATE_CHANNE=beta
AWS_ZONE=us-west-2
VM_TYPE=hvm
AMI_VARS=$(BUILD)/ami.tf

export

all: worker

help:
	@echo "Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )"
	@echo "Eg. make worker"

destroy: 
	@echo "Usage: make destroy_<resource>"
	@echo "Eg. make destroy_worker"

destroy_all: destroy_worker destroy_etcd destroy_iam destroy_route53 destroy_s3 destroy_vpc

clean_all: clean_worker clean_etcd clean_iam clean_route53 clean_s3 clean_vpc

# Load all resouces makefile
include resources/makefiles/*.mk

.PHONY: all destroy destroy_all clean_all help