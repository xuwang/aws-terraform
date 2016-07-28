rds: init_rds
	cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for rds to be ready
	sleep 10

plan_rds: init_rds
	cd $(BUILD)/rds; $(TF_GET); $(TF_PLAN)

plan_destroy_rds:
	cd $(BUILD)/rds; $(TF_DESTROY_PLAN)

destroy_rds: 
	cd $(BUILD)/rds; $(TF_DESTROY)

init_rds: vpc
	mkdir -p $(BUILD)/rds
	cp -rf $(RESOURCES)/terraforms/rds/rds.tf $(BUILD)/rds
	ln -sf $(BUILD)/*.tf $(BUILD)/rds

gen_rds_pass:
	# Todo: generate or get db_user/db_password

.PHONY: rds plan_rds plan_destroy_rds destroy_rds init_rds gen_rds_pass
