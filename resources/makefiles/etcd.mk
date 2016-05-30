# ETCD_TARGETS must include all resources defined in terraform/etcd.tf
ETCD_TARGETS := -target=aws_security_group.etcd -target=module.etcd

etcd: plan_etcd vpc s3 iam upload_etcd_userdata 
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c etcd; \
		$(TF_APPLY) ${ETCD_TARGETS}
	@$(MAKE) etcd_ips

plan_etcd: init_etcd
	cd $(BUILD); \
		$(TF_PLAN) ${ETCD_TARGETS}

refresh_etcd: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) ${ETCD_TARGETS}
	@$(MAKE) etcd_ips

destroy_etcd: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d etcd; \
		$(TF_DESTROY) ${ETCD_TARGETS}; \
		rm -f $(BUILD)/etcd.tf

clean_etcd: destroy_etcd
	rm -f $(BUILD)/etcd.tf

init_etcd: init
	cp -rf $(RESOURCES)/terraforms/etcd.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

upload_etcd_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh etcd $(CONFIG)/cloudinit-etcd.def

etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

.PHONY: etcd destroy_etcd refresh_etcd plan_etcd init_etcd clean_etcd upload_etcd_userdata etcd_ips
