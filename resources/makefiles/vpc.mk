vpc: plan_vpc
	cd $(BUILD); \
	$(TF_APPLY) -target module.vpc 
	# Wait for vpc/subnets to be ready
	sleep 5

plan_vpc: init_vpc
	cd $(BUILD); \
	$(TF_PLAN) -target module.vpc;

refresh_vpc: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.vpc

destroy_vpc: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.vpc

clean_vpc: destroy_vpc
	rm -f $(BUILD)/module-vpc.tf

init_vpc: init
	cp -rf $(RESOURCES)/terraforms/module-vpc.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: vpc destroy_vpc refresh_vpc plan_vpc init_vpc clean_vpc

