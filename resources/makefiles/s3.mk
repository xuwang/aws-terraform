s3: plan_s3
	cd $(BUILD); $(TF_APPLY)
	# Wait for s3/subnets to be ready
	sleep 5

plan_s3: init_s3
	cd $(BUILD); $(TF_PLAN)

destroy_s3:
	rm -f $(BUILD)/s3*.tf; 
	cd $(BUILD); $(TF_APPLY)

init_s3: init
	cp -rf $(RESOURCES)/terraforms/s3*.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: s3 destroy_s3 plan_s3 init_s3

