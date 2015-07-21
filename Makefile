CWD := $(shell pwd)
PROFILE_NAME := coreos-cluster
PROFILE := "profile $(PROFILE_NAME)"
SRC := $(CWD)/coreos-cluster
BUILD := $(CWD)/build
SCRIPTS := $(CWD)/scripts
# Terraform dirs and var files
TF_COMMON := $(BUILD)/tfcommon
KEY_VARS := $(TF_COMMON)/keys.tfvars
VPC_VARS_TF=$(TF_COMMON)/vpc-vars.tf
VPC_VARS := $(TF_COMMON)/vpc-vars.tfvars
R53_VARS := $(TF_COMMON)/route53-vars.tfvars
# Terraform commands
TF_PLAN := terraform plan --var-file=$(KEY_VARS)
TF_APPLY := terraform apply --var-file=$(KEY_VARS)
TF_REFRESH := terraform refresh --var-file=$(KEY_VARS)
TF_DESTROY_PLAN := terraform plan -destroy --var-file=$(KEY_VARS) --out=destroy.tfplan
TF_DESTROY_APPLY := terraform apply destroy.tfplan
TF_SHOW := terraform show
TF_DESTROY_PLAN_FILE := destroy.tfplan
# For get-ami.sh
COREOS_UPDATE_CHANNE=beta
AWS_ZONE=us-west-2
VM_TYPE=pv
# Exports all above vars
export

# Note the order of BUILD_SUBDIRS is significant, because there are dependences on destroy_all
BUILD_SUBDIRS := iam s3 route53 vpc

# Get goals for sub-module
SUBGOALS := $(filter-out $(BUILD_SUBDIRS), $(MAKECMDGOALS))

# Get the sub-module name
GOAL := $(firstword $(MAKECMDGOALS))

# Get the sub-module dir
BUILD_SUBDIR := build/$(GOAL)

# Copy sub-module dir to build
$(BUILD_SUBDIR): $(KEY_VARS)
	cp -R $(SRC)/$(GOAL) $(BUILD)

# Generate keys.tfvars from AWS credentials
$(KEY_VARS): | $(BUILD)
	echo aws_access_key = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/credentials $(PROFILE_NAME) aws_access_key_id)\" > $(KEY_VARS)
	echo aws_secret_key = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/credentials $(PROFILE_NAME) aws_secret_access_key)\" >> $(KEY_VARS)	
	echo aws_region = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/config $(PROFILE) region)\" >> $(KEY_VARS)

# Create build dir and copy tfcommon to build
$(BUILD):
	mkdir -p $(BUILD)
	cp -Rf  $(SRC)/tfcommon $(BUILD)
	$(SCRIPTS)/get-ami.sh >> $(TF_COMMON)/override.tf

# This goal is usefull if we need to reset aws keys or default ami, etc.
reset_tfcommon: $(KEY_VARS)

all: vpc

show_all:
	cd build; for dir in $(BUILD_SUBDIRS); do \
        test -d $$dir && $(MAKE) -C $$dir -i show ; \
        exit 0; \
    done

destroy:
	echo Use \"make destroy_all\" to destroy ALL resources

destroy_all:
	cd build; for dir in $(BUILD_SUBDIRS); do \
        test -d $$dir && $(MAKE) -C $$dir -i destroy ; \
    done
	rm -rf $(BUILD)

vpc: | $(BUILD_SUBDIR)
	$(MAKE) -C $(BUILD)/vpc $(SUBGOALS)

# This goal is needed because some other goals dependents on $(VPC_VARS)
$(VPC_VARS):
	make vpc apply

s3: | $(BUILD_SUBDIR)
	$(MAKE) -C $(BUILD_SUBDIR) $(SUBGOALS)

iam: | $(BUILD_SUBDIR)
	$(MAKE) -C $(BUILD_SUBDIR) $(SUBGOALS)

route53: | $(VPC_VARS) $(BUILD_SUBDIR)
	$(MAKE) -C $(BUILD_SUBDIR) $(SUBGOALS)

# This goal is needed because some other goals dependents on $(R53_VARS)
$(R53_VARS):
	make route53 apply

etcd: | $(BUILD_SUBDIR)
	$(MAKE) -C $(BUILD_SUBDIR) $(SUBGOALS)

# Terraform Targets
plan apply destroy_plan refresh show init:
	# Goals for sub-module $(MAKECMDGOALS)

.PHONY: show_all destroy_all init_build reset_tfcommon
.PHONY: pall lan apply destroy_plan destroy refresh show init 
.PHONY: vpc s3 iam route53 etcd