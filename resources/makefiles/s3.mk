s3: plan_s3
	cd $(BUILD); \
	$(TF_APPLY) -target module.s3

plan_s3: init_s3
	cd $(BUILD); \
	$(TF_PLAN) -target module.s3;

refresh_s3: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.s3

destroy_s3: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.s3

clean_s3: destroy_s3
	rm -f $(BUILD)/module-s3.tf

init_s3: init
	cp -rf $(RESOURCES)/terraforms/module-s3.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: s3 destroy_s3 refresh_s3 plan_s3 init_s3 clean_s3
