etcd: vpc s3 iam plan_etcd upload_etcd_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c etcd; \
		$(TF_APPLY) -target module.etcd
	@$(MAKE) etcd_ips

plan_etcd: plan_vpc plan_s3 plan_iam init_etcd
	cd $(BUILD); \
		$(TF_PLAN) -target module.etcd;

refresh_etcd: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.etcd
	@$(MAKE) etcd_ips

destroy_etcd: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d etcd; \
		$(TF_DESTROY) -target module.etcd.aws_autoscaling_group.etcd; \
		$(TF_DESTROY) -target module.etcd.aws_launch_configuration.etcd; \
		$(TF_DESTROY) -target module.etcd 

clean_etcd: destroy_etcd
	rm -f $(BUILD)/module-etcd.tf

init_etcd: init
	cp -rf $(RESOURCES)/terraforms/module-etcd.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_etcd_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh etcd $(CONFIG)/cloudinit-etcd.def

etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

.PHONY: etcd destroy_etcd refresh_etcd plan_etcd init_etcd clean_etcd upload_etcd_userdata etcd_ips
