worker: init_worker
	cd $(BUILD)/$@ ; $(SCRIPTS)/tf_apply_confirm.sh
	@$(MAKE) gen_worker_vars
	@$(MAKE) get_worker_ips

# Use this for ongoing changes if you only changed worker.tf.
worker_only: worker_key
	mkdir -p $(BUILD)/worker
	cp -rf $(RESOURCES)/terraforms/worker/worker.tf $(BUILD)/worker
	ln -sf $(BUILD)/*.tf $(BUILD)/worker
	cd $(BUILD)/worker ; $(SCRIPTS)/tf_apply_confirm.sh
	@$(MAKE) gen_worker_vars
	@$(MAKE) get_worker_ips

plan_worker: init_worker
	cd $(BUILD)/worker; $(TF_GET); $(TF_PLAN)

init_worker: etcd worker_key
	mkdir -p $(BUILD)/worker
	cp -rf $(RESOURCES)/terraforms/worker/worker.tf $(BUILD)/worker
	ln -sf $(BUILD)/*.tf $(BUILD)/worker
	@if [[ "X$(APP_REPOSITORY_DEPLOYKEY)" != "X" ]] && [[ -f $(APP_REPOSITORY_DEPLOYKEY) ]]; then \
  		cat $(APP_REPOSITORY_DEPLOYKEY) >> $(BUILD)/cloud-config/worker.yaml.tmpl; \
  	fi

destroy_worker: destroy_worker_key 
	cd $(BUILD)/worker; $(TF_DESTROY)

show_worker:  
	cd $(BUILD)/worker; $(TF_SHOW) 

worker_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-worker;

destroy_worker_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-worker;

clean_worker:
	rm -rf $(BUILD)/worker

gen_worker_vars:
	cd $(BUILD)/worker; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/worker_vars.tf

get_worker_ips:
	@echo "worker public ips: " `$(SCRIPTS)/get-ec2-public-id.sh worker`


# Call this explicitly to re-load user_data
update_worker_user_data:
	cd $(BUILD)/worker; \
		${TF_TAINT} aws_s3_bucket_object.worker_cloud_config ; \
		$(TF_APPLY)

.PHONY: worker worker_only destroy_worker plan_destroy_worker plan_worker init_worker get_worker_ips update_worker_user_data
.PHONY: show_worker worker_key destroy_worker_key gen_worker_vars clean_worker
