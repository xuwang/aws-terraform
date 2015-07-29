iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_GET); \
	$(TF_APPLY) -target module.iam

destroy_iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.iam; \
	rm -f $(CONFIG)/aws-file.yaml

plan_iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_GET); \
	$(TF_PLAN) -target module.iam;

refresh_iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.iam

.PHONY: iam destroy_iam refresh_iam

