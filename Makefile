# Profile/Cluster name
PROFILE := coreos-cluster

# Working Directories
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
MODULES := $(ROOT_DIR)modules
RESOURCES := $(ROOT_DIR)resources
BUILD := $(ROOT_DIR)build
SCRIPTS := $(ROOT_DIR)scripts
CONFIG := $(BUILD)/cloud-config
CERTS := $(BUILD)/certs

# Terraform files
TF_PORVIDER := $(BUILD)/provider.tf
TF_DESTROY_PLAN := $(BUILD)/destroy.tfplan
TF_APPLY_PLAN := $(BUILD)/destroy.tfplan

# Terraform commands
TF_GET := terraform get -update
TF_SHOW := terraform show
TF_GRAPH := terraform graph
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

all:
	echo "Usage: make (<resource> | destroy_<resource> | refresh_<resource> | show | graph )"
	echo "Eg. make worker"

destroy: 
	echo "Usage: make destroy_<resource>"
	echo "Eg. make destroy_worker"

# Load all resouces makefile
include mk/*.mk

.PHONY: all destroy