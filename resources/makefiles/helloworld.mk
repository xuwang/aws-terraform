helloworld: etcd plan_helloworld upload_configs upload_helloworld_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c helloworld; \
		$(TF_APPLY) -target module.helloworld
	@$(MAKE) helloworld_ips

plan_helloworld: plan_etcd init_helloworld
	cd $(BUILD); \
		$(TF_PLAN) -target module.helloworld;

refresh_helloworld: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.helloworld
	@$(MAKE) helloworld_ips

destroy_helloworld: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d helloworld; \
		$(TF_DESTROY) -target module.helloworld.aws_autoscaling_group.helloworld; \
		$(TF_DESTROY) -target module.helloworld.aws_launch_configuration.helloworld; \
		$(TF_DESTROY) -target module.helloworld 

clean_helloworld: destroy_helloworld
	rm -f $(BUILD)/module-helloworld.tf

init_helloworld: init
	cp -rf $(RESOURCES)/terraforms/module-helloworld.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

helloworld_ips:
	@echo "helloworld public ips: " `$(SCRIPTS)/get-ec2-public-id.sh helloworld`

upload_helloworld_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh helloworld $(CONFIG)/cloudinit-helloworld.def

# upload_confs
# uploads confing folder to config s3 bucket; by keeping the folder structure

.PHONY: helloworld destroy_helloworld refresh_helloworld plan_helloworld init_helloworld
.PHONY: clean_helloworld upload_helloworld_userdata helloworld_ips
.PHONY: upload_configs