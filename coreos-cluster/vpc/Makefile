
all: apply

# Terraform Targets
plan: | init
	$(TF_PLAN)

apply: | plan
	$(TF_APPLY); $(SCRIPTS)/gen-vpc-vars.sh

destroy_plan: | init
	$(TF_DESTROY_PLAN)

destroy: | destroy_plan
	if [ -a $(TF_DESTROY_PLAN_FILE) ]; \
	then \
		$(TF_DESTROY_APPLY); \
		rm -f $(TF_DESTROY_PLAN_FILE); \
		rm -f $(TF_COMMON)/vpc.tf; \
		rm -f $(VPC_VARS); \
	else \
		echo "Noting to destroy"; \
	fi

show: | init
	$(TF_SHOW)

refresh: | init
	$(TF_REFRESH) --var-file=$(VPC_VARS)
	$(SCRIPTS)/gen-vpc-vars.sh

init: 
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf