#this_make := $(lastword $(MAKEFILE_LIST))
#$(warning $(this_make))

worker: | clean_worker etcd plan_worker
	cd $(BUILD); $(TF_APPLY);
	@$(MAKE) get_etcd_ips
	@$(MAKE) get_worker_ips

plan_worker: init_worker
	cd $(BUILD); $(TF_GET); $(TF_PLAN)

clean_worker:
	rm -f $(BUILD)/worker*.tf

worker_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-worker; \

destroy_worker_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-worker;

plan_destroy_worker:
	$(eval TMP := $(shell mktemp -d -t worker ))
	mv $(BUILD)/worker*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/worker*.tf $(BUILD)
	rmdir $(TMP)

destroy_worker: destroy_worker_key clean_worker
	cd $(BUILD); $(TF_APPLY) ;

init_worker: init_etcd init_iam
	cp -rf $(RESOURCES)/terraforms/worker.tf $(RESOURCES)/terraforms/vpc-subnet-worker.tf $(BUILD)
	$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-worker

# Call this explicitly to re-load user_data
update_worker_user_data:
	cd $(BUILD); \
		${TF_TAINT} aws_s3_bucket_object.worker_cloud_config ; \
		$(TF_APPLY)

# EFS has to be enabled for the account
init_efs_target:
	cp -rf $(RESOURCES)/terraforms/worker-efs-targe.tf $(RESOURCES)/terraforms/worker-efs-target $(BUILD)
	cd $(BUILD); $(TF_GET);

get_worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`

.PHONY: init_worker init_efs_target get_worker_ips destroy_worker clean_worker
.PHONT: plan_destroy_worker plan_worker update_worker_user_data worker worker_key destroy_worker_key

