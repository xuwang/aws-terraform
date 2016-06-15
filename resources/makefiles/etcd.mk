this_make := $(lastword $(MAKEFILE_LIST))
$(warning $(this_make))

etcd: plan_etcd
	cd $(BUILD); $(TF_APPLY);
	$(MAKE) etcd_ips

plan_etcd: init_etcd
	cd $(BUILD); $(TF_PLAN)

etcd_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c etcd; \

plan_destroy_etcd:
	$(eval TMP := $(shell mktemp -d -t etcd ))
	mv $(BUILD)/etcd*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/etcd*.tf $(BUILD)
	rmdir $(TMP)

destroy_etcd: 
	rm -f $(BUILD)/etcd*.tf; \ 
	cd $(BUILD); $(TF_APPLY) 
	$(SCRIPTS)/aws-keypair.sh -d etcd;

init_etcd: init_vpc init_iam
	cp -rf $(RESOURCES)/terraforms/etcd*.tf $(BUILD)
	cd $(BUILD); $(TF_GET); \
		$(SCRIPTS)/aws-keypair.sh -c etcd

# Call this explicitly to re-load user_data
update_etcd_user_data:
	cd $(BUILD); \
		${TF_TAINT} aws_s3_bucket_object.etcd_cloud_config ; \
		$(TF_APPLY)

etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

.PHONY: etcd destroy_etcd plan_destroy_etcd plan_etcd init_etcd etcd_ips update_etcd_user_data