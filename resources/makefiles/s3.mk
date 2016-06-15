this_make := $(lastword $(MAKEFILE_LIST))
$(warning $(this_make))

s3: plan_s3
	cd $(BUILD); $(TF_APPLY)
	# Wait for s3/subnets to be ready
	sleep 5

plan_s3: init_s3
	cd $(BUILD); $(TF_PLAN)

plan_destroy_s3:
	$(eval TMP := $(shell mktemp -d -t s3 ))
	mv $(BUILD)/s3*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/s3*.tf $(BUILD)
	rmdir $(TMP)

destroy_s3:  
	rm -f $(BUILD)/s3*.tf
	cd $(BUILD); $(TF_APPLY)

init_s3: init
	cp -rf $(RESOURCES)/terraforms/s3*.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

.PHONY: s3 plan_destroy_s3 destroy_s3 plan_s3 init_s3

