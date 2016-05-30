# ADMIRAL_TARGETS must include all resources defined in terraform/admiral.tf
ADMIRAL_TARGETS := -target=aws_security_group.admiral -target=module.admiral

admiral: plan_admiral etcd upload_admiral_userdata 
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c admiral; \
		$(TF_APPLY) ${ADMIRAL_TARGETS}
	@$(MAKE) admiral_ips

plan_admiral: init_admiral
	cd $(BUILD); \
		$(TF_PLAN) ${ADMIRAL_TARGETS}

refresh_admiral: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) ${ADMIRAL_TARGETS}
	@$(MAKE) admiral_ips

destroy_admiral: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d admiral; \
		$(TF_DESTROY) ${ADMIRAL_TARGETS}; \
		rm -f $(BUILD)/admiral.tf

clean_admiral: destroy_admiral
	rm -f $(BUILD)/admiral.tf

init_admiral: init
	cp -rf $(RESOURCES)/terraforms/admiral.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

admiral_ips:
	@echo "admiral public ips: " `$(SCRIPTS)/get-ec2-public-id.sh admiral`

upload_admiral_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh admiral $(CONFIG)/cloudinit-admiral.def

.PHONY: admiral destroy_admiral refresh_admiral plan_admiral init_admiral clean_admiral upload_admiral_userdata admiral_ips
