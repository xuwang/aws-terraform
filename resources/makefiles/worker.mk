worker: plan_worker
	cd $(BUILD); $(TF_APPLY);
	@$(MAKE) worker_ips

plan_worker: init_worker
	cd $(BUILD); $(TF_PLAN)

worker_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c worker; \

destroy_worker: 
	rm -f $(BUILD)/worker*.tf; 
	cd $(BUILD); $(TF_APPLY); \
	$(SCRIPTS)/aws-keypair.sh -d worker;

init_worker: init_vpc init_iam
	cp -rf $(RESOURCES)/terraforms/worker*.tf $(BUILD)
	cd $(BUILD); $(TF_GET); \
		$(SCRIPTS)/aws-keypair.sh -c worker

update_worker_user_data:
	cd $(BUILD); \
		grep '.yaml' cloud-config/cloudinit-worker.def | xargs cat > cloud-config/worker.yaml.tmpl; \
		${TF_TAINT} aws_s3_bucket_object.worker_cloud_config ; \
		$(TF_APPLY)

worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`

.PHONY: worker destroy_worker plan_worker init_worker worker_ips update_worker_user_data

