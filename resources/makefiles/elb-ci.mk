elb_ci: vpc plan_elb_ci
	cd $(BUILD)/elb-ci ; $(SCRIPTS)/tf-apply-confirm.sh
	@$(MAKE) get_elb_ci_dns_name

plan_elb_ci: plan_vpc init_elb_ci
	cd $(BUILD)/elb-ci; $(TF_PLAN)

destroy_elb_ci: | $(TF_PORVIDER)
	cd $(BUILD)/elb-ci; $(TF_DESTROY) 

plan_destroy_elb_ci:
	cd $(BUILD)/elb-ci; $(TF_DESTROY_PLAN)

# init elb build dir, may add init_route53 as dependence if dns registration is needed.
init_elb_ci: | $(SITE_CERT) init route53
	mkdir -p $(BUILD)/elb-ci
	cp -rf $(RESOURCES)/terraforms/elb-ci/ci.tf $(BUILD)/elb-ci
	ln -sf $(BUILD)/*.tf $(BUILD)/elb-ci

get_elb_ci_dns_name:
	@cd $(BUILD)/elb-ci; elb_name=`$(TF_OUTPUT) elb_name` ; echo `$(SCRIPTS)/get-dns-name.sh $$elb_name`

.PHONY: elb_ci destroy_elb_ci plan_elb_ci init_elb_ci certs get_elb_ci_dns_name plan_destroy_elb_ci
