vpc: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_GET); \
	$(TF_APPLY) -target module.vpc

destroy_vpc: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.vpc

plan_vpc: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_GET); \
	$(TF_PLAN) -target module.vpc;

refresh_vpc: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.vpc

.PHONY: vpc destroy_vpc refresh_vpc plan_vpc

