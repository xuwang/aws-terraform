elb: vpc plan_elb
	cd $(BUILD); \
		$(TF_APPLY) -target module.elb
	@$(MAKE) elb_names

plan_elb: plan_vpc init_elb
	cd $(BUILD); \
		$(TF_PLAN) -target module.elb;

refresh_elb: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.elb
	@$(MAKE) elb_names

destroy_elb: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_DESTROY) -target module.elb
	rm -f $(CONFIG)/aws-files.yaml

clean_elb: destroy_elb
	rm -f $(BUILD)/module-elb.tf

# init elb build dir, may add init_route53 as dependence if dns registration is needed.
init_elb: | $(SITE_CERT) init
	cp -rf $(RESOURCES)/terraforms/module-elb.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

elb_names: 
	@echo ELB names: `aws elb describe-load-balancers --profile $(AWS_PROFILE) | jq --raw-output '.LoadBalancerDescriptions[].DNSName'`

.PHONY: elb destroy_elb refresh_elb plan_elb init_elb clean_elb certs elb_names
