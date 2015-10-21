route53: vpc plan_route53
	cd $(BUILD); \
	$(TF_APPLY) -target module.route53

plan_route53: plan_vpc init_route53
	cd $(BUILD); \
	$(TF_PLAN) -target module.route53;

refresh_route53: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.route53

destroy_route53: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.route53;

clean_route53: destroy_route53
	rm -f $(BUILD)/module-route53.tf

init_route53: init
	cp -rf $(RESOURCES)/terraforms/module-route53.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: route53 destroy_route53 refresh_route53 plan_route53 init_route53 clean_route53

