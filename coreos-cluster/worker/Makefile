
EC2_ROLE=worker

all: apply

clean:
	# let top level do the clean job

# Terraform Targets
plan: | init
	$(TF_PLAN)  --var-file=$(VPC_VARS)

apply: | plan
	$(TF_APPLY) --var-file=$(VPC_VARS);
	echo "EC2 public ips: `$(SCRIPTS)/get-ec2-public-id.sh $(EC2_ROLE)`"

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
	echo "EC2 public ips: `$(SCRIPTS)/get-ec2-public-id.sh $(EC2_ROLE)`"

refresh: | init
	$(TF_REFRESH) --var-file=$(VPC_VARS)

init: 
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf
	ln -s -f $(TF_COMMON)/vpc-vars.tf vpc-vars.tf
	# fix AWS-ACCOUNT with aws account id in all tf and json files
	$(SCRIPTS)/substitute-AWS-ACCOUNT.sh
	# create ec2 keypaire and upload to s3://AWS_ACCOUNT-coreos-cluster-config/keypairs/
	$(SCRIPTS)/create-and-upload-keypair.sh $(EC2_ROLE)
	# create user-data and upload to s3://AWS_ACCOUNT-coreos-cluster-config/worker/cloud-config.yaml
	$(SCRIPTS)/substitute-AWS-ACCOUNT.sh