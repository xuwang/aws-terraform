vpc: init_vpc
	@cd $(BUILD)/$@ ; $(SCRIPTS)/tf_apply_confirm.sh
	# Wait for vpc/subnets to be ready
	sleep 5
	$(MAKE) gen_vpc_vars

plan_vpc: init_vpc
	cd $(BUILD)/vpc; $(TF_GET); $(TF_PLAN)

destroy_vpc:
	@echo "In $@."
	@$(MAKE) confirm
	cd $(BUILD)/vpc; $(TF_DESTROY)

show_vpc:  
	cd $(BUILD)/vpc; $(TF_SHOW) 

init_vpc: init
	mkdir -p $(BUILD)/vpc
	rsync -av $(RESOURCES)/terraforms/vpc/ $(BUILD)/vpc
	ln -sf $(BUILD)/*.tf $(BUILD)/vpc

clean_vpc:
	rm -rf $(BUILD)/vpc

gen_vpc_vars:
	cd $(BUILD)/vpc; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/vpc_vars.tf

.PHONY: vpc plan_destroy_vpc destroy_vpc plan_vpc init_vpc show_vpc clean_vpc

