CWD := $(shell pwd)
SRC := $(CWD)/coreos-cluster
BUILD := $(CWD)/build
SCRIPTS := $(CWD)/scripts
TF_COMMON := $(BUILD)/tfcommon
KEY_VARS := $(TF_COMMON)/keys.tfvars
VPC_VARS_TF=$(TF_COMMON)/vpc-vars.tf
VPC_VARS := $(TF_COMMON)/vpc-vars.tfvars
R53_VARS := $(TF_COMMON)/route53-vars.tfvars
PROFILE_NAME := coreos-cluster
PROFILE := "profile $(PROFILE_NAME)"
TF_PLAN := terraform plan --var-file=$(KEY_VARS)
TF_APPLY := terraform apply --var-file=$(KEY_VARS)
TF_REFRESH := terraform refresh --var-file=$(KEY_VARS)
TF_DESTROY_PLAN := terraform plan -destroy --var-file=$(KEY_VARS) --out=destroy.tfplan
TF_DESTROY_APPLY := terraform apply destroy.tfplan
TF_SHOW := terraform show
TF_DESTROY_PLAN_FILE := destroy.tfplan
# Exports all above vars
export

# Note the order of BUILD_SUBDIRS is significant, because there are dependences on clean_all
BUILD_SUBDIRS := iam s3 route53 vpc

all: vpc

show_all:
	cd build; for dir in $(BUILD_SUBDIRS); do \
        test -d $$dir && $(MAKE) -C $$dir -i show ; \
    done

clean_all:
	cd build; for dir in $(BUILD_SUBDIRS); do \
        test -d $$dir && $(MAKE) -C $$dir -i destroy ; \
    done
	rm -rf $(BUILD)
	
$(BUILD): init_build

init_build:
	mkdir -p $(BUILD)
	cp -Rf  $(SRC)/tfcommon $(BUILD)

$(KEY_VARS): | $(BUILD)
	echo aws_access_key = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/credentials $(PROFILE_NAME) aws_access_key_id)\" > $(KEY_VARS)
	echo aws_secret_key = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/credentials $(PROFILE_NAME) aws_secret_access_key)\" >> $(KEY_VARS)	
	echo aws_region = \"$(shell $(SCRIPTS)/read_cfg.sh $(HOME)/.aws/config $(PROFILE) region)\" >> $(KEY_VARS)


vpc: | $(KEY_VARS)
	cp -R $(SRC)/vpc $(BUILD); cd $(BUILD)/vpc; $(MAKE) $(filter-out vpc, $(MAKECMDGOALS))

# This goal is needed because some other goals dependents on $(VPC_VARS)
$(VPC_VARS): | $(KEY_VARS)
	cp -R $(SRC)/vpc $(BUILD); cd $(BUILD)/vpc; $(MAKE) apply;

s3: | $(KEY_VARS)
	cp -R $(SRC)/s3 $(BUILD); cd $(BUILD)/s3; $(MAKE) $(filter-out s3, $(MAKECMDGOALS))

iam: | $(KEY_VARS)
	cp -R $(SRC)/iam $(BUILD); cd $(BUILD)/iam; $(MAKE) $(filter-out iam, $(MAKECMDGOALS))

route53: | $(VPC_VARS)
	cp -R $(SRC)/route53 $(BUILD); cd $(BUILD)/route53; $(MAKE) $(filter-out route53, $(MAKECMDGOALS))

# This goal is needed because some other goals dependents on $(R53_VARS)
$(R53_VARS): | $(VPC_VARS)
	cp -R $(SRC)/route53 $(BUILD); cd $(BUILD)/route53; $(MAKE) apply

# Terraform Targets
plan apply destroy_plan destroy refresh show init:
	@echo $(MAKECMDGOALS)

.PHONY: pall lan apply destroy_plan destroy refresh show init clean show_all clean_all init_build
.PHONY: vpc s3 iam route53