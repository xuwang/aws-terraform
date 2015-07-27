
all: apply

# Terraform Targets
plan: | init
	$(TF_PLAN)

apply: | init
	$(TF_APPLY)
	# Generate cloudinit file for aws envvars 
	$(SCRIPTS)/gen-cloudinit-aws-env.sh >> $(TF_COMMON)/cloud-config/files.yaml

destroy_plan: | init
	$(TF_DESTROY_PLAN)

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

refresh: | init
	$(TF_REFRESH)

init: 
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf
	$(SCRIPTS)/substitute-AWS-ACCOUNT.sh