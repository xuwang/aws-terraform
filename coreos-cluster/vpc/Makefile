
all: apply

clean:
	# let top level do the clean job

# Terraform Targets
plan:
	$(TF_PLAN)

apply: | plan
	$(TF_APPLY); $(SCRIPTS)/gen-network-tfvars.sh

destroy_plan:
	$(TF_DESTROY_PLAN); cat /dev/null > network.tfvars; cat /dev/null > network.tf

destroy: | destroy_plan
	test -s $(TF_DESTROY_PLAN_FILE) || { echo "Noting to destroy"; exit 0; } ; \
		$(TF_DESTROY_APPLY); rm -f $(TF_DESTROY_PLAN_FILE)

show:
	$(TF_SHOW)