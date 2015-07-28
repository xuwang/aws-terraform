all: apply

clean:
	# let top level do the clean job

# Terraform Targets
plan: | init
	$(TF_PLAN) --var-file=$(VPC_VARS)

apply: | init
	# create ec2 keypaire and upload to s3://AWS_ACCOUNT-coreos-cluster-config/keypairs/
	$(SCRIPTS)/create-and-upload-keypair.sh $(GOAL)
	# create user-data and upload to s3://AWS_ACCOUNT-coreos-cluster-config/worker/cloud-config.yaml
	$(SCRIPTS)/gen-userdata.sh $(PROFILE_NAME) $(GOAL)
	# terraform apply
	$(TF_APPLY) --var-file=$(VPC_VARS);
	$(MAKE) show_ip

destroy_plan: | init
	$(TF_DESTROY_PLAN) --var-file=$(VPC_VARS)

destroy: | destroy_plan
	if [ -a $(TF_DESTROY_PLAN_FILE) ]; \
	then \
		$(TF_DESTROY_APPLY); \
		rm -f $(TF_DESTROY_PLAN_FILE); \
	else \
		echo "Noting to destroy"; \
	fi

show: | init
	$(TF_SHOW)
	$(MAKE) show_ip

show_ip:
	echo "$(GOAL) public ips: " `$(SCRIPTS)/get-ec2-public-id.sh $(GOAL)`

refresh: | init
	$(TF_REFRESH) --var-file=$(VPC_VARS)

init: | $(VPC_VARS)
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf
	ln -s -f $(TF_COMMON)/vpc-vars.tf vpc-vars.tf
	# fix AWS-ACCOUNT with aws account id in all tf and json files
	$(SCRIPTS)/substitute-AWS-ACCOUNT.sh

$(VPC_VARS):
	$(MAKE) -C $(ROOT_DIR) vpc apply

.PHONY: all apply destroy_plan destroy show show_ip refresh init