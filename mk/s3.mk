s3: | $(TF_PORVIDER)
	cd $(BUILD); \
	cp $(RESOURCES)/s3.tf .; \
	$(TF_GET); \
	$(TF_APPLY) -target module.s3

destroy_s3: | $(BUILD)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.s3

refresh_s3: | $(BUILD)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.s3

.PHONY: s3 destroy_s3 refresh_s3
