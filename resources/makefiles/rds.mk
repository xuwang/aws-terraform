#this_make := $(lastword $(MAKEFILE_LIST))
#$(warning $(this_make))

rds: plan_rds confirm
	cd $(BUILD); $(TF_APPLY)
	# Wait for s3/subnets to be ready
	sleep 5

plan_rds: clean_rds init_rds
	cd $(BUILD); $(TF_GET); $(TF_PLAN)

clean_rds:
	cd $(BUILD); rm -f $(BUILD)/rds*.tf

plan_destroy_rds:
	$(eval TMP := $(shell mktemp -d -t s3 ))
	mv $(BUILD)/rds*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/rds.tf $(BUILD)
	rmdir $(TMP)

destroy_rds:  
	rm -f $(BUILD)/rds*.tf
	cd $(BUILD); $(TF_APPLY)

init_rds: init_vpc
	cp -rf $(RESOURCES)/terraforms/rds/ $(BUILD)/rds

gen_rds_pass:
	# Todo: generate or get db_user/db_password

.PHONY: rds plan_rds plan_destroy_rds destroy_rds init_rds gen_rds_pass
