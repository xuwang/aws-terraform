#this_make := $(lastword $(MAKEFILE_LIST))
#$(warning $(this_make))

admiral: etcd plan_admiral
	cd $(BUILD); $(TF_APPLY);
	@$(MAKE) get_etcd_ips
	@$(MAKE) get_admiral_ips

plan_admiral: init_admiral
	cd $(BUILD); $(TF_PLAN)

admiral_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c admiral; \

plan_destroy_admiral:
	$(eval TMP := $(shell mktemp -d -t admiral ))
	mv $(BUILD)/admiral*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/admiral*.tf $(BUILD)
	rmdir $(TMP)

destroy_admiral:  
	rm -f $(BUILD)/admiral*.tf
	cd $(BUILD); $(TF_APPLY) 
	$(SCRIPTS)/aws-keypair.sh -d admiral;

init_admiral: init_etcd init_iam
	cp -rf $(RESOURCES)/terraforms/admiral.tf $(RESOURCES)/terraforms/vpc-subnet-admiral.tf $(BUILD)
	cd $(BUILD); $(TF_GET); \
		$(SCRIPTS)/aws-keypair.sh -c admiral

# Call this explicitly to re-load user_data
update_admiral_user_data:
	cd $(BUILD); \
		${TF_TAINT} aws_s3_bucket_object.admiral_cloud_config ; \
		$(TF_APPLY)

get_admiral_ips:
	@echo "admiral public ips: " `$(SCRIPTS)/get-ec2-public-id.sh admiral`

.PHONY: admiral plan_destroy_admiral destroy_admiral plan_admiral init_admiral get_admiral_ips update_admiral_user_data
