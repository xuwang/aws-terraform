iam: plan_iam 
	@echo "#### Working on $@"
	cd $(BUILD); $(TF_APPLY)
	# Wait for iam/subnets to be ready
	sleep 5

plan_iam: init_iam plan_s3
	cd $(BUILD); $(TF_GET); $(TF_PLAN)

plan_destroy_iam:
	$(eval TMP := $(shell mktemp -d -t iam ))
	mv $(BUILD)/iam*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/iam*.tf $(BUILD)
	rmdir $(TMP)

destroy_iam:  
	rm -f $(BUILD)/iam*.tf
	cd $(BUILD); $(TF_APPLY)

init_iam: init_s3
	cp -rf $(RESOURCES)/terraforms/iam*.tf $(BUILD)

.PHONY: iam plan_destroy_iam destroy_iam plan_iam init_iam
