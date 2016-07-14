this_make := $(lastword $(MAKEFILE_LIST))
$(warning $(this_make))

vpc: plan_vpc
	cd $(BUILD); $(TF_APPLY)
	# Wait for vpc/subnets to be ready
	sleep 5

plan_vpc: init_vpc
	cd $(BUILD); $(TF_GET); $(TF_PLAN)

plan_destroy_vpc:
	$(eval TMP := $(shell mktemp -d -t vpc ))
	mv $(BUILD)/vpc*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/vpc*.tf $(BUILD)
	rmdir $(TMP)

destroy_vpc:  
	rm -f $(BUILD)/vpc*.tf;
	cd $(BUILD); $(TF_APPLY) 

init_vpc: init
	rsync -av $(RESOURCES)/terraforms/vpc*.tf $(BUILD)

.PHONY: vpc plan_destroy_vpc destroy_vpc plan_vpc init_vpc

