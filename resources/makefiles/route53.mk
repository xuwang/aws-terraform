
route53: init_route53
	@cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	@$(MAKE) gen_route53_vars

plan_route53: plan_vpc init_route53
	cd $(BUILD)/route53; $(TF_PLAN)

init_route53: vpc
	mkdir -p $(BUILD)/route53
	rsync -avq  $(RESOURCES)/terraforms/route53/ $(BUILD)/route53
	ln -sf $(BUILD)/*.tf $(BUILD)/route53

plan_destroy_route53:
	cd $(BUILD); $(TF_PLAN)

gen_route53_vars:
	cd $(BUILD)/route53; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/route53_vars.tf

destroy_route53:
	cd $(BUILD)/route53; $(TF_DESTROY)

clean_route53: destroy_route53
	rm -f $(BUILD)/module-route53.tf

.PHONY: route53 plan_route53 init_route53 plan_destroy_route53 gen_route53_vars destroy_route53 clean_route53
