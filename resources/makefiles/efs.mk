# Create EFS cluster
efs: plan_efs
	cd $(BUILD)/efs; $(TF_APPLY);
	sleep 5
	$(MAKE) gen_efs_vars

init_efs: init_vpc
	mkdir -p $(BUILD)/efs
	rsync -avq  $(RESOURCES)/terraforms/efs/ $(BUILD)/efs
	ln -sf $(BUILD)/*.tf $(BUILD)/efs

destroy_efs:
	cd $(BUILD)/efs; $(TF_DESTROY)

gen_efs_vars:
	cd $(BUILD)/efs; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/efs_vars.tf

plan_destroy_efs:
	$(eval TMP := $(shell mktemp -d -t efs ))
	mv $(BUILD)/efs/efs*.tf $(TMP)
	cd $(BUILD)/efs; $(TF_PLAN)
	mv $(TMP)/efs*.tf $(BUILD)/efs
	rmdir $(TMP)

plan_efs: init_efs
	cd $(BUILD)/efs; $(TF_GET); $(TF_PLAN)

.PHONY: efs init_efs gen_etcd_vars plan_destroy_efs destroy_efs plan_efs
