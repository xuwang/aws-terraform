etcd: init_etcd upload_etcd_userdata
	cd $(BUILD); \
	$(SCRIPTS)/create-and-upload-keypair.sh etcd; \
	$(TF_APPLY) -target module.etcd; \
	@$(MAKE) etcd_ips

plan_etcd: init_etcd
	cd $(BUILD); \
	$(TF_PLAN) -target module.etcd;

refresh_etcd: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.etcd

destroy_etcd: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.etcd.aws_autoscaling_group.etcd; \
	$(TF_DESTROY) -target module.etcd.aws_launch_configuration.etcd; \
	$(TF_DESTROY) -target module.etcd 

clean_etcd: destroy_etcd
	rm -f $(BUILD)/module-etcd.tf

init_etcd: vpc s3 iam
	cp -rf $(RESOURCES)/terraforms/module-etcd.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_etcd_userdata:
	cd $(BUILD); \
	$(SCRIPTS)/gen-userdata.sh etcd $(CONFIG)/etcd-cloudinit.def

etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

.PHONY: etcd destroy_etcd refresh_etcd plan_etcd init_etcd clean_etcd upload_etcd_userdata etcd_ips
