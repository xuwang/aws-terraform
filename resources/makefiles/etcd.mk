etcd: plan_etcd confirm
	cd $(BUILD)/etcd; $(TF_APPLY)
	# Wait for vpc/subnets to be ready
	sleep 5
	$(MAKE) gen_etcd_vars
	@$(MAKE) get_etcd_ips

plan_etcd: init_etcd
	cd $(BUILD)/etcd; $(TF_GET); $(TF_PLAN)

destroy_etcd: destroy_etcd_key 
	cd $(BUILD)/etcd; $(TF_DESTROY)

show_etcd:  
	cd $(BUILD)/etcd; $(TF_SHOW) 

etcd_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-etcd;

destroy_etcd_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-etcd;

init_etcd: vpc iam s3 etcd_key 
	mkdir -p $(BUILD)/etcd
	rsync -av  $(RESOURCES)/terraforms/etcd/ $(BUILD)/etcd
	ln -sf $(BUILD)/*.tf $(BUILD)/etcd

clean_etcd:
	rm -rf $(BUILD)/etcd

gen_etcd_vars:
	cd $(BUILD)/etcd; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/etcd_vars.tf

get_etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

# Call this explicitly to re-load user_data
update_etcd_user_data:
	cd $(BUILD)/etcd; \
		${TF_TAINT} aws_s3_bucket_object.etcd_cloud_config ; \
		$(TF_APPLY)


.PHONY: etcd destroy_etcd plan_destroy_etcd plan_etcd init_etcd get_etcd_ips update_etcd_user_data
.PHONY: show_etcd etcd_key destroy_etcd_key gen_etcd_vars clean_etcd
