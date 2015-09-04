iam: plan_iam
	cd $(BUILD); \
	$(TF_APPLY) -target module.iam

plan_iam: init_iam
	cd $(BUILD); \
	$(TF_PLAN) -target module.iam;

refresh_iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.iam

destroy_iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.iam; \
	rm -f $(CONFIG)/aws-files.yaml

clean_iam: destroy_iam
	rm -f $(BUILD)/module-iam.tf

init_iam: init
	cp -rf $(RESOURCES)/terraforms/module-iam.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: iam destroy_iam refresh_iam plan_iam init_iam clean_iam

