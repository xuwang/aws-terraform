# WORKER_TARGETS must include all resources defined in terraform/worker.tf
WORKER_TARGETS := -target=aws_security_group.worker -target=module.worker

worker: plan_worker etcd upload_worker_userdata 
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c worker; \
		$(TF_APPLY) ${worker_TARGETS}
	@$(MAKE) worker_ips

plan_worker: init_worker
	cd $(BUILD); \
		$(TF_PLAN) ${worker_TARGETS}

refresh_worker: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) ${worker_TARGETS}
	@$(MAKE) worker_ips

destroy_worker: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -d worker; \
		$(TF_DESTROY) ${worker_TARGETS}; \
		rm -f $(BUILD)/worker.tf

clean_worker: destroy_worker
	rm -f $(BUILD)/worker.tf

init_worker: init
	cp -rf $(RESOURCES)/terraforms/worker.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`

upload_worker_userdata: init_build_dir
	cd $(BUILD); \
		$(SCRIPTS)/gen-userdata.sh worker $(CONFIG)/cloudinit-worker.def

.PHONY: worker destroy_worker refresh_worker plan_worker init_worker clean_worker upload_worker_userdata worker_ips