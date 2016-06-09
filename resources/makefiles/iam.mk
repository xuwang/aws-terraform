iam: plan_iam 
	cd $(BUILD); $(TF_APPLY)
	# Wait for iam/subnets to be ready
	sleep 5

plan_iam: init_iam plan_s3
	cd $(BUILD); $(TF_PLAN)

destroy_iam:
	rm -f $(BUILD)/iam*.tf; 
	cd $(BUILD); $(TF_APPLY)

init_iam: init_s3
	cp -rf $(RESOURCES)/terraforms/iam*.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: iam destroy_iam plan_iam init_iam
