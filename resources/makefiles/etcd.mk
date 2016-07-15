this_make := $(lastword $(MAKEFILE_LIST))
$(warning $(this_make))

etcd: plan_etcd
	cd $(BUILD); $(TF_APPLY);
	$(MAKE) get_etcd_ips

plan_etcd: init_etcd
	cd $(BUILD); $(TF_GET); $(TF_PLAN)

etcd_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-etcd;

destroy_etcd_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-etcd;

plan_destroy_etcd:
	$(eval TMP := $(shell mktemp -d -t etcd ))
	mv $(BUILD)/etcd*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv $(TMP)/etcd*.tf $(BUILD)
	rmdir $(TMP)

destroy_etcd: destroy_etcd_key
	rm -f $(BUILD)/etcd*.tf
	cd $(BUILD); $(TF_APPLY);

init_etcd: init_vpc init_iam etcd_key
	cp -rf $(RESOURCES)/terraforms/etcd*.tf $(BUILD)

# Call this explicitly to re-load user_data
update_etcd_user_data:
	cd $(BUILD); \
		${TF_TAINT} aws_s3_bucket_object.etcd_cloud_config ; \
		$(TF_APPLY)

get_etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

.PHONY: etcd destroy_etcd plan_destroy_etcd plan_etcd init_etcd get_etcd_ips update_etcd_user_data
.PHONY: destroy_etcd_key
