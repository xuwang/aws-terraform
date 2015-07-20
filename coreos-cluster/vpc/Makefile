
all: apply

clean:
	# let top level do the clean job

# Terraform Targets
plan: | init
	$(TF_PLAN)

apply: | plan
	$(TF_APPLY); $(SCRIPTS)/gen-network-tfvars.sh

destroy_plan: | init
	$(TF_DESTROY_PLAN)

destroy: | destroy_plan
	if [ -a $(TF_DESTROY_PLAN_FILE) ]; \
	then \
		$(TF_DESTROY_APPLY); \
		rm -f $(TF_DESTROY_PLAN_FILE); \
		cat /dev/null > $(TF_COMMON)/network.tf; \
		cat /dev/null > $(TF_COMMON)/network.tfvars; \
	else \
		echo "Noting to destroy"; \
	fi


show: | init
	$(TF_SHOW)

init: 
	ln -s -f $(TF_COMMON)/override.tf override.tf
	ln -s -f $(TF_COMMON)/variables.tf variables.tf
	ln -s -f $(TF_COMMON)/provider.tf provider.tf