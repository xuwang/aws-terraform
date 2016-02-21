efs: vpc plan_efs
	cd $(BUILD); \
	$(TF_APPLY) -target module.efs

plan_efs: plan_vpc init_efs
	cd $(BUILD); \
	$(TF_PLAN) -target module.efs;

refresh_efs: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.efs

destroy_efs: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.efs; \
	rm -f $(CONFIG)/aws-files.yaml

clean_efs: destroy_efs
	rm -f $(BUILD)/module-efs.tf

init_efs: init
	cp -rf $(RESOURCES)/terraforms/module-efs.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

gen_efs_pass:
	# Todo: generate or get db_user/db_password

.PHONY: efs destroy_efs refresh_efs plan_efs init_efs clean_efs
