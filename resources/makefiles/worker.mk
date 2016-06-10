worker: plan_worker
	cd $(BUILD); $(TF_APPLY);
	@$(MAKE) etcd_ips
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

init_worker: init_etcd init_iam
	cp -rf $(RESOURCES)/terraforms/worker.tf $(RESOURCES)/terraforms/vpc-subnet-worker.tf $(BUILD)
	cd $(BUILD); $(TF_GET); \
		$(SCRIPTS)/aws-keypair.sh -c worker

update_worker_user_data:
	cd $(BUILD); \
		${TF_TAINT} aws_s3_bucket_object.worker_cloud_config ; \
		$(TF_APPLY)

# EFS has to be enabled for the account
init_efs_target:
	cp -rf $(RESOURCES)/terraforms/worker-efs-targe.tf $(RESOURCES)/terraforms/worker-efs-target $(BUILD)
	cd $(BUILD); $(TF_GET);

worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`

.PHONY: worker destroy_worker plan_worker init_worker worker_ips update_worker_user_data

