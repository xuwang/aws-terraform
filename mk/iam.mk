iam: | $(TF_PORVIDER)
	cd $(BUILD); \
	cp $(RESOURCES)/iam.tf .; \
	$(TF_GET); \
	$(TF_APPLY) -target module.iam

destroy_iam: | $(BUILD)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.iam; \
	rm -f $(CONFIG)/aws-file.yaml

refresh_iam: | $(BUILD)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.iam

.PHONY: iam destroy_iam refresh_iam

