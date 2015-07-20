CWD := $(shell pwd)
SOURCE := $(CWD)/coreos-cluster
BUILD := $(CWD)/build
SCRIPTS := $(CWD)/scripts
TF_COMMON := $(BUILD)/tfcommon
KEY_VARS := $(TF_COMMON)/keys.tfvars
VPC_VARS := $(TF_COMMON)/network.tfvars
PROFILE_NAME := coreos-cluster
PROFILE := "profile $(PROFILE_NAME)"
TF_PLAN := terraform plan --var-file=$(KEY_VARS)
TF_APPLY := terraform apply --var-file=$(KEY_VARS)
TF_DESTROY_PLAN := terraform plan -destroy --var-file=$(KEY_VARS) --out=destroy.tfplan
TF_DESTROY_APPLY := terraform apply destroy.tfplan
TF_SHOW := terraform show terraform.tfstate
TF_DESTROY_PLAN_FILE := destroy.tfplan
# Exports all above vars
export

all: vpc

show_all: 
	test -d $(BUILD)/vpc && { cd $(BUILD)/vpc; $(MAKE) -i show; }; exit 0
	

clean:	
	test -d $(BUILD)/vpc && { $(MAKE) -i -C $(BUILD)/vpc clean; }; exit 0
	rm -rf $(BUILD)
	
$(BUILD): 
	mkdir -p $(BUILD)
	cp -R  $(SOURCE)/tfcommon $(BUILD)

$(KEY_VARS): | $(BUILD)
	echo aws_access_key = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/credentials $(PROFILE_NAME) aws_access_key_id)\" > $(KEY_VARS)
	echo aws_secret_key = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/credentials $(PROFILE_NAME) aws_secret_access_key)\" >> $(KEY_VARS)	
	echo aws_region = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/config $(PROFILE) region)\" >> $(KEY_VARS)

$(VPC_VARS): | vpc

vpc: | vpc_init
	cd $(BUILD)/vpc; $(MAKE) $(filter-out vpc, $(MAKECMDGOALS))

vpc_init:  | $(KEY_VARS)
	cp -R $(SOURCE)/vpc $(BUILD)

# Terraform Targets
plan apply destroy_plan destroy show:
	@echo $(MAKECMDGOALS)