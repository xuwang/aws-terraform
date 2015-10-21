admiral: etcd plan_admiral upload_admiral_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c admiral; \
		$(TF_APPLY) -target module.admiral
	@$(MAKE) admiral_ips

plan_admiral: plan_etcd init_admiral
	cd $(BUILD); \
		$(TF_PLAN) -target module.admiral;

refresh_admiral: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.admiral
	@$(MAKE) admiral_ips

destroy_admiral: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d admiral; \
		$(TF_DESTROY) -target module.admiral.aws_autoscaling_group.admiral; \
		$(TF_DESTROY) -target module.admiral.aws_launch_configuration.admiral; \
		$(TF_DESTROY) -target module.admiral 

clean_admiral: destroy_admiral
	rm -f $(BUILD)/module-admiral.tf

init_admiral: init
	cp -rf $(RESOURCES)/terraforms/module-admiral.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

admiral_ips:
	@echo "admiral public ips: " `$(SCRIPTS)/get-ec2-public-id.sh admiral`

upload_admiral_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh admiral $(CONFIG)/cloudinit-admiral.def

.PHONY: admiral destroy_admiral refresh_admiral plan_admiral init_admiral clean_admiral upload_admiral_userdata admiral_ips
