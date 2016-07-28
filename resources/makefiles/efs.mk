# Create EFS cluster servers and EFS mount targets
efs: init_efs
	@cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	@$(MAKE) gen_efs_vars

plan_efs: init_efs
	cd $(BUILD)/efs; $(TF_GET); $(TF_PLAN)

init_efs: vpc
	mkdir -p $(BUILD)/efs
	rsync -avq  $(RESOURCES)/terraforms/efs/ $(BUILD)/efs
	ln -sf $(BUILD)/*.tf $(BUILD)/efs

destroy_efs:
	cd $(BUILD)/efs; $(TF_DESTROY)

gen_efs_vars:
	cd $(BUILD)/efs; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/efs_vars.tf

.PHONY: efs init_efs gen_etcd_vars plan_destroy_efs destroy_efs plan_efs
