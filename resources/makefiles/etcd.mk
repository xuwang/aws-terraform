
etcd: plan_etcd
	@echo "#### Working on $@"
	cd $(BUILD); $(TF_APPLY);
	$(MAKE) upload_etcd_key
	$(MAKE) get_etcd_ips

plan_etcd: init_etcd
	@echo "#### Working on $@"
	cd $(BUILD); \
	    for i in *.tf ; do \
	      [[ -f $(RESOURCES)/terraforms/$$i ]] && rsync -avzq $(RESOURCES)/terraforms/$$i $(BUILD)/ ; \
	    done; $(TF_GET); $(TF_PLAN)

create_etcd_key:
	@echo "#### Working on $@"
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-etcd;

upload_etcd_key:
	@echo "#### Working on $@"
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -u $(CLUSTER_NAME)-etcd;

destroy_etcd_key:
	@echo "#### Working on $@"
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-etcd;

plan_destroy_etcd:
	@echo "#### Working on $@"
	$(eval TMP := $(shell mktemp -d -t etcd ))
	mv $(BUILD)/etcd*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv $(TMP)/etcd*.tf $(BUILD)
	rmdir $(TMP)

destroy_etcd: destroy_etcd_key
	@echo "#### Working on $@"
	rm -f $(BUILD)/etcd*.tf
	cd $(BUILD); $(TF_APPLY);

init_etcd: init_vpc init_iam
	@echo "#### Working on $@"
	cp -rf $(RESOURCES)/terraforms/etcd*.tf $(BUILD)
	$(MAKE) create_etcd_key 

# Call this explicitly to re-load user_data
update_etcd_user_data:
	@echo "#### Working on $@"
	cd $(BUILD); \
		${TF_TAINT} aws_s3_bucket_object.etcd_cloud_config ; \
		$(TF_APPLY)

get_etcd_ips:
	@echo "etcd public ips: " `$(SCRIPTS)/get-ec2-public-id.sh etcd`

.PHONY: etcd destroy_etcd plan_destroy_etcd plan_etcd init_etcd get_etcd_ips update_etcd_user_data
.PHONY: create_etcd_key upload_etcd_key destroy_etcd_key
