s3: plan_s3
	cd $(BUILD)/s3; $(TF_APPLY)
	# Wait for vpc/subnets to be ready
	sleep 5
	$(MAKE) gen_s3_vars

plan_s3: init_s3
	cd $(BUILD)/s3; $(TF_GET); $(TF_PLAN)

destroy_s3:  
	cd $(BUILD)/s3; $(TF_DESTROY)
	rm $(BUILD)/s3_vars.tf

show_s3:  
	cd $(BUILD)/s3; $(TF_SHOW) 

init_s3: init
	mkdir -p $(BUILD)/s3
	rsync -av  $(RESOURCES)/terraforms/s3*.tf $(BUILD)/s3
	ln -sf $(BUILD)/*.tf $(BUILD)/s3

gen_s3_vars:
	cd $(BUILD)/s3; ${SCRIPTS}/gen_tf_vars.sh > $(BUILD)/s3_vars.tf

.PHONY: s3 plan_destroy_s3 destroy_s3 plan_s3 init_s3 gen_s3_vars

