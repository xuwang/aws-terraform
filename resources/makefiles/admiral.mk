admiral: init_admiral
	cd $(BUILD)/$@ ; $(SCRIPTS)/tf_apply_confirm.sh
	# Wait for vpc/subnets to be ready
	sleep 5
	$(MAKE) gen_admiral_vars
	@$(MAKE) get_admiral_ips

# Use this for ongoing changes if you only changed admiral.tf.
admiral_only:
	cp -rf $(RESOURCES)/terraforms/admiral/admiral.tf $(BUILD)/admiral
	cd $(BUILD)/admiral; $(SCRIPTS)/tf_apply_confirm.sh
	@$(MAKE) get_admiral_ips

plan_admiral: init_admiral
	cd $(BUILD)/admiral; $(TF_GET); $(TF_PLAN)

destroy_admiral: destroy_admiral_key 
	cd $(BUILD)/admiral; $(TF_DESTROY)

show_admiral:  
	cd $(BUILD)/admiral; $(TF_SHOW) 

admiral_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-admiral;

destroy_admiral_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-admiral;

init_admiral: etcd admiral_key
	mkdir -p $(BUILD)/admiral
	cp -rf $(RESOURCES)/terraforms/admiral/admiral.tf $(BUILD)/admiral
	ln -sf $(BUILD)/*.tf $(BUILD)/admiral
	@if [[ "X$(APP_REPOSITORY_DEPLOYKEY)" != "X" ]] && [[ -f $(APP_REPOSITORY_DEPLOYKEY) ]]; then \
  		cat $(APP_REPOSITORY_DEPLOYKEY) >> $(BUILD)/cloud-config/admiral.yaml.tmpl; \
  	fi

clean_admiral:
	rm -rf $(BUILD)/admiral

gen_admiral_vars:
	cd $(BUILD)/admiral; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/admiral_vars.tf

get_admiral_ips:
	@echo "admiral public ips: " `$(SCRIPTS)/get-ec2-public-id.sh admiral`

# EFS target
admiral_efs_target: plan_admiral_efs_target
	cd $(BUILD)/admiral; $(TF_GET); $(TF_APPLY);

plan_admiral_efs_target:
	cp -rf $(RESOURCES)/terraforms/admiral/admiral-efs-target.tf $(BUILD)/admiral
	cd $(BUILD)/admiral; $(TF_GET); $(TF_PLAN)

# Call this explicitly to re-load user_data
update_admiral_user_data:
	cd $(BUILD)/admiral; \
		${TF_TAINT} aws_s3_bucket_object.admiral_cloud_config ; \
		$(TF_APPLY)

.PHONY: admiral destroy_admiral plan_destroy_admiral plan_admiral init_admiral get_admiral_ips update_admiral_user_data
.PHONY: show_admiral admiral_key destroy_admiral_key gen_admiral_vars init_efs_target clean_admiral
