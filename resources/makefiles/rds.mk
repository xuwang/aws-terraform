DB_PWD := $(BUILD)/rds/override.tf

rds: init_rds $(DB_PWD)
	cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for rds to be ready
	sleep 10

# Only for db update. No other dependency change.
rds_only:
	rsync -av $(RESOURCES)/terraforms/rds/ $(BUILD)/rds
	cd $(BUILD)/rds ; ln -sf ../*.tf . ; $(SCRIPTS)/tf-apply-confirm.sh

plan_rds: init_rds
	cd $(BUILD)/rds; $(TF_GET); $(TF_PLAN)

plan_destroy_rds:
	cd $(BUILD)/rds; $(TF_DESTROY_PLAN)

destroy_rds: 
	cd $(BUILD)/rds; $(TF_DESTROY)

init_rds: vpc route53
	mkdir -p $(BUILD)/rds
	rsync -av $(RESOURCES)/terraforms/rds/ $(BUILD)/rds
	cd $(BUILD)/rds ; ln -sf ../*.tf .

$(DB_PWD): 
	$(SCRIPTS)/gen-rds-password.sh $(DB_PWD)

gen_db_pwd: $(DB_PWD)

.PHONY: rds plan_rds plan_destroy_rds destroy_rds rds_only init_rds gen_rds_password gen_db_pwd
