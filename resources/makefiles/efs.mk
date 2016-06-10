# EFS is an AWS preview feature. You need to requset to enable this feature in your account.
efs: plan_efs
	cd $(BUILD); $(TF_APPLY);

plan_efs: init_efs
	cd $(BUILD); \
	$(TF_PLAN)

destroy_efs: | $(TF_PORVIDER)
	rm -f $(BUILD)/efs.tf; 
	cd $(BUILD); $(TF_APPLY)

init_efs: init_vpc
	cp -rf $(RESOURCES)/terraforms/efs.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: efs destroy_efs plan_efs init_efs clean_efs
