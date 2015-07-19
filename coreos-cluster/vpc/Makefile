
all: apply

clean: destroy

# Terraform Targets
plan:
	$(TF_PLAN)

apply: | plan
	$(TF_APPLY); $(SCRIPTS)/gen-network-tfvars.sh

destroy_plan:
	$(TF_DESTROY_PLAN); cat /dev/null > network.tfvars; cat /dev/null > network.tf

destroy: | destroy_plan
	$(TF_DESTROY_APPLY)

show:
	$(TF_SHOW)