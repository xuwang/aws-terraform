###################
## Customization ##
###################
# Change here or use environment variables, e.g. export AWS_PROFILE=<aws profile name>.

# Default AWS profile and cluster name. Please choose cluster name carefully. It will used as prefix in many AWS resources to be created.
AWS_PROFILE ?= coreos-cluster
CLUSTER_NAME ?= coreos-cluster
# Application repository. Automatically synced to /var/lib/apps every minute
APP_REPOSITORY ?= https://github.com/dockerage/coreos-cluster-apps
APP_REPOSITORY_DEPLOYKEY ?= ''

# Domain: default domain for Route53 zone and a self-signed *.domain cert for default ELBs.
APP_DOMAIN ?= 'example.com'

# For get-ami.sh
COREOS_UPDATE_CHANNE ?= beta
AWS_REGION ?= us-west-2
VM_TYPE ?= hvm

# To prevent you from mistakenly using a wrong account (and end up destroying live environment),
# a list of allowed AWS account IDs should be defined:
#ALLOWED_ACCOUNT_IDS := "123456789012","012345678901"
AWS_ACCOUNT := $(shell aws --profile ${AWS_PROFILE} iam get-user | jq -r ".User.Arn" | grep -Eo '[[:digit:]]{12}')
AWS_USER := $(shell aws --profile ${AWS_PROFILE} iam get-user | jq -r ".User.UserName")
ALLOWED_ACCOUNT_IDS := "$(AWS_ACCOUNT)"

# Working Directories
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)scripts
MODULES := $(ROOT_DIR)modules
RESOURCES := $(ROOT_DIR)resources
TF_RESOURCES := $(ROOT_DIR)resources/terraforms
BUILD := $(ROOT_DIR)build
BUILD_SUBDIRS = $(shell [ -d $(BUILD) ] && cd $(BUILD) && ls -d */ | tr '/' ' ')
CONFIG := $(BUILD)/cloud-config
CERTS := $(BUILD)/certs
SITE_CERT := $(CERTS)/site.pem
POLICIES := $(BUILD)/policies
AMI_VAR := ami.tf

# LOCKKEY to prevent multiple terraform runs. The private key for the lock will be put in $HOME/.aws/{LOCK_KEYNAME}.pem
# which is used to valide if you own the lock.
LOCK_KEYNAME := $(CLUSTER_NAME)-tfstate-lock

# Terraform files
TF_PORVIDER := provider.tf
TF_DESTROY_PLAN_OUT := destroy.tfplan
TF_APPLY_PLAN := apply.tfplan
TF_STATE := terraform.tfstate

# Terraform commands
# Note: for production, set -refresh=true to be safe
TF_APPLY := terraform apply -refresh=false
# Note: for production, remove --force to confirm destroy.
TF_DESTROY := terraform destroy -force
TF_DESTROY_PLAN := terraform plan -destroy -refresh=false
TF_GET := terraform get -update
TF_GRAPH := terraform graph -draw-cycles -verbose
TF_PLAN := terraform plan -module-depth=1 -refresh=false
TF_SHOW := terraform show -module-depth=1
TF_REFRESH := terraform refresh
TF_TAINT := terraform taint -allow-missing
TF_OUTPUT := terraform output


# cidr block to allow ssh; default to  $(curl -s http://ipinfo.io/ip)/32)
# TF_VAR_allow_ssh_cidr := 

# All resources used in destroy_all, in the order of dependencies
ALL_RESOURCES := admiral worker etcd iam efs s3 elb_ci elb_gitlab elb_dockerhub route53 vpc

##########################
## End of customization ##
##########################

export

all: worker admiral

help:
	@echo "Usage: make plan_<resource> | <resource> | plan_destroy_<resource> | destroy_<resource>"
	@echo "Or make show_<resource> | graph"
	@echo "Or make plan_destroy_all | destroy_all"
	@echo "Available resources: vpc s3 route53 iam efs elb etcd worker admiral rds"
	@echo "For example: make plan_worker # to show what resources are planned for worker"

lock:
	$(SCRIPTS)/session-lock.sh -l $(LOCK_KEYNAME)

unlock:
	$(SCRIPTS)/session-lock.sh -u $(LOCK_KEYNAME)

session_start: lock
	$(MAKE) pull_tf_state

session_end:
	@if ! git diff-index --name-status --exit-code HEAD -- ; then \
	    echo "You have unpublished changes:"; exit 1 ; \
	fi
	$(MAKE) push_tf_state
	$(SCRIPTS)/session-lock.sh -u $(LOCK_KEYNAME) && rm session_start

plan_destroy_all:
	@echo $(BUILD_SUBDIRS)
	$(foreach resource,$(BUILD_SUBDIRS),cd $(BUILD)/$(resource) && $(TF_DESTROY_PLAN)  2> /tmp/destroy.err;)

confirm:
	@echo "CONTINUE? [Y/N]: "; read ANSWER; \
	if [ ! "$$ANSWER" == "Y" ]; then \
		echo "Exiting." ; exit 1 ; \
    fi

destroy_all: | plan_destroy_all confirm
	@echo "Will destroy $(ALL_RESOURCES)"
	@for i in $(ALL_RESOURCES); do \
	  if [ -d $(BUILD)/$$i ]; then \
	    $(MAKE) destroy_$$i ; \
	  fi ; \
	done
	rm -rf $(BUILD)

destroy: 
	@echo "Usage: make destroy_<resource> | make plan_destroy_all | make destroy_all"
	@echo "For example: make destroy_worker"
	@echo "Node: destroy may fail because of outstanding dependences"

show_all:
	@echo $(BUILD_SUBDIRS)
	$(foreach resource,$(BUILD_SUBDIRS),$(TF_SHOW) $(BUILD)/$(resource)/terraform.tfstate 2> /dev/null;)

# TODO: Push/Pull terraform states from a tf state repo
# For team work, you need to commit terraform to a remote location, such as git repo, S3 
# Should implement a locking method to prevent alter infrastructure at the same time.
pull_tf_state:
	@mkdir -p $(BUILD)
	@echo pull terraform state from ...
	#git pull --rebase 

push_tf_state:
	@echo push terraform state to ....
	#git push

# Load all resouces makefile
include resources/makefiles/*.mk

.PHONY: all confirm destroy destroy_all lock unlock plan_destroy_all help pull_tf_state push_tf_state
