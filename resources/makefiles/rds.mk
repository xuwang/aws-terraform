rds: init_rds vpc
	cd $(BUILD); \
	$(TF_APPLY) -target module.rds

plan_rds: init_rds plan_vpc
	cd $(BUILD); \
	$(TF_PLAN) -target module.rds;

refresh_rds: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.rds

destroy_rds: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.rds; \
	rm -f $(CONFIG)/aws-files.yaml

clean_rds: destroy_rds
	rm -f $(BUILD)/module-rds.tf

init_rds:
	cp -rf $(RESOURCES)/terraforms/module-rds.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

gen_rds_pass:
	# Todo: generate or get db_user/db_password

.PHONY: rds destroy_rds refresh_rds plan_rds init_rds clean_rds
