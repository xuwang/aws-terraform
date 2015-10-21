dockerhub: etcd plan_dockerhub upload_dockerhub_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c dockerhub; \
		$(TF_APPLY) -target module.dockerhub
	@$(MAKE) dockerhub_ips

plan_dockerhub: plan_etcd init_dockerhub
	cd $(BUILD); \
		$(TF_PLAN) -target module.dockerhub;

refresh_dockerhub: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.dockerhub
	@$(MAKE) dockerhub_ips

destroy_dockerhub: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d dockerhub; \
		$(TF_DESTROY) -target module.dockerhub.aws_autoscaling_group.dockerhub; \
		$(TF_DESTROY) -target module.dockerhub.aws_launch_configuration.dockerhub; \
		$(TF_DESTROY) -target module.dockerhub 

clean_dockerhub: destroy_dockerhub
	rm -f $(BUILD)/module-dockerhub.tf

init_dockerhub: init
	cp -rf $(RESOURCES)/terraforms/module-dockerhub.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

dockerhub_ips:
	@echo "dockerhub public ips: " `$(SCRIPTS)/get-ec2-public-id.sh dockerhub`

upload_dockerhub_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh dockerhub $(CONFIG)/cloudinit-dockerhub.def

.PHONY: dockerhub destroy_dockerhub refresh_dockerhub plan_dockerhub init_dockerhub 
.PHONY: clean_dockerhub upload_dockerhub_userdata dockerhub_ips
