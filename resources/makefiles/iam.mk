iam: plan_iam
	cd $(BUILD)/iam; $(TF_APPLY)
	# Wait for vpc/subnets to be ready
	sleep 5
	$(MAKE) gen_iam_vars

plan_iam: init_iam
	cd $(BUILD)/iam; $(TF_GET); $(TF_PLAN)

destroy_iam:  
	cd $(BUILD)/iam; $(TF_DESTROY)
	rm $(BUILD)/iam_vars.tf

show_iam:  
	cd $(BUILD)/iam; $(TF_SHOW) 

init_iam: s3
	mkdir -p $(BUILD)/iam
	rsync -av  $(RESOURCES)/terraforms/iam*.tf $(BUILD)/iam
	ln -sf $(BUILD)/*.tf $(BUILD)/iam

clean_iam:
	rm -rf $(BUILD)/iam

gen_iam_vars:
	cd $(BUILD)/iam; ${SCRIPTS}/gen_tf_vars.sh > $(BUILD)/iam_vars.tf

.PHONY: iam plan_destroy_iam destroy_iam plan_iam init_iam gen_iam_vars clean_iam

