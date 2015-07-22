
all: apply

clean:
	# let top level do the clean job

# Terraform Targets
plan: | init
	$(TF_PLAN)  --var-file=$(VPC_VARS)

apply: | plan
	$(TF_APPLY) --var-file=$(VPC_VARS);

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

refresh: | init
	$(TF_REFRESH) --var-file=$(VPC_VARS)

init: 
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf
	ln -s -f $(TF_COMMON)/vpc-vars.tf vpc-vars.tf