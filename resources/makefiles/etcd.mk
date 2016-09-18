etcd: init_etcd 
	@cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for vpc/subnets to be ready
	sleep 5
	#@cd $(BUILD)/$@; $(TF_OUTPUT) && @$(MAKE) gen_vault_vars @$(MAKE) gen_etcd_vars
	$(MAKE) get_etcd_ips

etcd_only: init create_etcd_key
	mkdir -p $(BUILD)/etcd
	rsync -av  $(RESOURCES)/terraforms/etcd/ $(BUILD)/etcd
	cd $(BUILD)/etcd ; ln -sf ../*.tf .
	@if [[ "X$(APP_REPOSITORY_DEPLOYKEY)" != "X" ]] && [[ -f $(APP_REPOSITORY_DEPLOYKEY) ]]; then \
  		 cat $(APP_REPOSITORY_DEPLOYKEY) >> $(BUILD)/cloud-config/etcd.yaml.tmpl; \
  	fi
	@cd $(BUILD)/etcd ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for vpc/subnets to be ready
	sleep 5
	@$(MAKE) gen_etcd_vars
	$(MAKE) get_etcd_ips

plan_etcd: init_etcd
	cd $(BUILD)/etcd; $(TF_GET); $(TF_PLAN)

destroy_etcd: destroy_etcd_key 
	cd $(BUILD)/etcd; $(TF_DESTROY)

show_etcd:  
	cd $(BUILD)/etcd; $(TF_SHOW) 

create_etcd_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-etcd;

upload_etcd_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -u $(CLUSTER_NAME)-etcd;

destroy_etcd_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-etcd;

init_etcd: vpc iam s3 create_etcd_key 
	mkdir -p $(BUILD)/etcd
	rsync -av  $(RESOURCES)/terraforms/etcd/ $(BUILD)/etcd
	cd $(BUILD)/etcd ; rm -rf $(BUILD)/etcd_vars.tf etcd_vars.tf ; ln -sf ../*.tf .
	@if [[ "X$(APP_REPOSITORY_DEPLOYKEY)" != "X" ]] && [[ -f $(APP_REPOSITORY_DEPLOYKEY) ]]; then \
  		 cat $(APP_REPOSITORY_DEPLOYKEY) >> $(BUILD)/cloud-config/etcd.yaml.tmpl; \
  	fi

clean_etcd:
	rm -rf $(BUILD)/etcd $(BUILD)/etcd_vars.tf

gen_etcd_vars:
	cd $(BUILD)/etcd; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/etcd_vars.tf

get_etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh $(CLUSTER_NAME)-etcd`

# Call this explicitly to re-load user_data
update_etcd_user_data:
	cd $(BUILD)/etcd; \
		${TF_TAINT} aws_s3_bucket_object.etcd_cloud_config ; \
		$(TF_APPLY)

.PHONY: etcd etcd-only destroy_etcd plan_destroy_etcd plan_etcd init_etcd get_etcd_ips update_etcd_user_data
.PHONY: show_etcd create_etcd_key destroy_etcd_key gen_etcd_vars clean_etcd
