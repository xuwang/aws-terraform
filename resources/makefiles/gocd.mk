gocd: etcd plan_gocd upload_gocd_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c gocd; \
		$(TF_APPLY) -target module.gocd
	@$(MAKE) gocd_ips

plan_gocd: plan_etcd init_gocd
	cd $(BUILD); \
		$(TF_PLAN) -target module.gocd;

refresh_gocd: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.gocd
	@$(MAKE) gocd_ips

destroy_gocd: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d gocd; \
		$(TF_DESTROY) -target module.gocd.aws_autoscaling_group.gocd; \
		$(TF_DESTROY) -target module.gocd.aws_launch_configuration.gocd; \
		$(TF_DESTROY) -target module.gocd 

clean_gocd: destroy_gocd
	rm -f $(BUILD)/module-gocd.tf

init_gocd: init
	cp -rf $(RESOURCES)/terraforms/module-gocd.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

gocd_ips:
	@echo "gocd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh gocd`

upload_gocd_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh gocd $(CONFIG)/cloudinit-gocd.def

.PHONY: gocd destroy_gocd refresh_gocd plan_gocd init_gocd 
.PHONY: clean_gocd upload_gocd_userdata gocd_ips