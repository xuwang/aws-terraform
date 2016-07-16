worker: plan_worker
	cd $(BUILD)/worker; $(TF_APPLY)
	# Wait for vpc/subnets to be ready
	sleep 5
	@$(MAKE) get_worker_ips

plan_worker: init_worker
	cd $(BUILD)/worker; $(TF_GET); $(TF_PLAN)

destroy_worker: destroy_worker_key 
	cd $(BUILD)/worker; $(TF_DESTROY)

show_worker:  
	cd $(BUILD)/worker; $(TF_SHOW) 

worker_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-worker;

destroy_worker_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-worker;

#init_worker: etcd
init_worker:
	mkdir -p $(BUILD)/worker
	rsync -av  $(RESOURCES)/terraforms/worker.tf $(BUILD)/worker
	ln -sf $(BUILD)/*.tf $(BUILD)/worker

clean_worker:
	rm -rf $(BUILD)/worker

gen_worker_vars:
	cd $(BUILD)/worker; ${SCRIPTS}/gen_tf_vars.sh > $(BUILD)/worker_vars.tf

get_worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`

# EFS has to be enabled for the account
init_efs_target:
	cp -rf $(RESOURCES)/terraforms/worker-efs-targe.tf $(RESOURCES)/terraforms/worker-efs-target $(BUILD)/worker
	cd $(BUILD)/worker; $(TF_GET);

# Call this explicitly to re-load user_data
update_worker_user_data:
	cd $(BUILD)/worker; \
		${TF_TAINT} aws_s3_bucket_object.worker_cloud_config ; \
		$(TF_APPLY)

.PHONY: worker destroy_worker plan_destroy_worker plan_worker init_worker get_worker_ips update_worker_user_data
.PHONY: show_worker worker_key destroy_worker_key gen_worker_vars init_efs_target clean_worker
