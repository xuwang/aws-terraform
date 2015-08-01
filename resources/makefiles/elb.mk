elb: init_elb
	cd $(BUILD); \
	$(TF_APPLY) -target module.elb

plan_elb: init_elb
	cd $(BUILD); \
	$(TF_PLAN) -target module.elb;

refresh_elb: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.elb

destroy_elb: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.elb; \
	rm -f $(CONFIG)/aws-files.yaml

clean_elb: destroy_elb
	rm -f $(BUILD)/module-elb.tf

init_elb: route53 | $(SITE_CERT)
	cp -rf $(RESOURCES)/terraforms/module-elb.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: elb destroy_elb refresh_elb plan_elb init_elb clean_elb certs
