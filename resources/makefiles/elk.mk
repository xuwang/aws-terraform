elk: etcd plan_elk upload_elk_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c elk; \
		$(TF_APPLY) -target module.elk
	@$(MAKE) elk_ips

plan_elk: plan_etcd init_elk
	cd $(BUILD); \
		$(TF_PLAN) -target module.elk;

refresh_elk: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.elk
	@$(MAKE) elk_ips

destroy_elk: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d elk; \
		$(TF_DESTROY) -target module.elk.aws_autoscaling_group.elk; \
		$(TF_DESTROY) -target module.elk.aws_launch_configuration.elk; \
		$(TF_DESTROY) -target module.elk 

clean_elk: destroy_elk
	rm -f $(BUILD)/module-elk.tf

init_elk: init
	cp -rf $(RESOURCES)/terraforms/module-elk.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

elk_ips:
	@echo "elk public ips: " `$(SCRIPTS)/get-ec2-public-id.sh elk`

upload_elk_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh elk $(CONFIG)/cloudinit-elk.def

.PHONY: elk destroy_elk refresh_elk plan_elk init_elk 
.PHONY: clean_elk upload_elk_userdata elk_ips