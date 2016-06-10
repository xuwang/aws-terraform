admiral: plan_admiral
	cd $(BUILD); $(TF_APPLY);
	@$(MAKE) admiral_ips

plan_admiral: init_admiral update_admiral_user_data
	cd $(BUILD); $(TF_PLAN)

admiral_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c admiral; \

destroy_admiral: 
	rm -f $(BUILD)/admiral*.tf; 
	cd $(BUILD); $(TF_APPLY); \
	$(SCRIPTS)/aws-keypair.sh -d admiral;

init_admiral: init_etcd init_iam
	cp -rf $(RESOURCES)/terraforms/admiral*.tf $(BUILD)
	cd $(BUILD); $(TF_GET); \
		$(SCRIPTS)/aws-keypair.sh -c admiral

update_admiral_user_data:
	cd $(BUILD); \
		cat cloud-config/admiral.yaml cloud-config/systemd-units.yaml cloud-config/files.yaml > cloud-config/admiral.yaml.tmpl; \
		${TF_TAINT} aws_s3_bucket_object.admiral_cloud_config ; \
		$(TF_APPLY)

admiral_ips:
	@echo "admiral public ips: " `$(SCRIPTS)/get-ec2-public-id.sh admiral`

.PHONY: admiral destroy_admiral plan_admiral init_admiral admiral_ips update_admiral_user_data