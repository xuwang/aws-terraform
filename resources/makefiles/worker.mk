worker: etcd plan_worker upload_worker_userdata
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c worker; \
		$(TF_APPLY) -target module.worker
	@$(MAKE) worker_ips

plan_worker: plan_etcd init_worker 
	cd $(BUILD); \
		$(TF_PLAN) -target module.worker;

refresh_worker: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.worker
	@$(MAKE) worker_ips

destroy_worker: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d worker; \
		$(TF_DESTROY) -target module.worker.aws_autoscaling_group.worker; \
		$(TF_DESTROY) -target module.worker.aws_launch_configuration.worker; \
		$(TF_DESTROY) -target module.worker 

clean_worker: destroy_worker
	rm -f $(BUILD)/module-worker.tf

init_worker: init
	cp -rf $(RESOURCES)/terraforms/module-worker.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`

upload_worker_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh worker $(CONFIG)/cloudinit-worker.def

.PHONY: worker destroy_worker refresh_worker plan_worker init_worker clean_worker upload_worker_userdata worker_ips
