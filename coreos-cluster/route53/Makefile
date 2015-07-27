
all: apply

# Terraform Targets
plan: | init
	$(TF_PLAN) --var-file=$(VPC_VARS);

apply: | init
	$(TF_APPLY) --var-file=$(VPC_VARS);

destroy_plan: | init
	$(TF_DESTROY_PLAN) --var-file=$(VPC_VARS) ; exit 0

destroy: | destroy_plan
	if [ -a $(TF_DESTROY_PLAN_FILE) ]; \
	then \
		$(TF_DESTROY_APPLY); \
		rm -f $(TF_DESTROY_PLAN_FILE); \
		rm -f $(R53_VARS); \
	else \
		echo "Noting to destroy"; \
	fi

show: | init
	$(TF_SHOW)

refresh: | init
	$(TF_REFRESH) --var-file=$(VPC_VARS)

init: | $(VPC_VARS)
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf
	ln -s -f $(VPC_VARS_TF) vpc-vars.tf

$(VPC_VARS):
	$(MAKE) -C $(ROOT_DIR) vpc apply

.PHONY: all apply destroy_plan destroy show refresh init $(VPC_VARS)