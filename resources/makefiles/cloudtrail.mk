cloudtrail: init_cloudtrail
	cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for cloudtrail to be ready
	sleep 10

# Only for cloudtrail update. No other dependency change.
cloudtrail_only:
	rsync -av $(RESOURCES)/terraforms/cloudtrail/ $(BUILD)/cloudtrail
	cd $(BUILD)/cloudtrail ; ln -sf ../*.tf . ; $(SCRIPTS)/tf-apply-confirm.sh

plan_cloudtrail: init_cloudtrail
	cd $(BUILD)/cloudtrail; $(TF_GET); $(TF_PLAN)

plan_destroy_cloudtrail:
	cd $(BUILD)/cloudtrail; $(TF_DESTROY_PLAN)

destroy_cloudtrail: 
	cd $(BUILD)/cloudtrail; $(TF_DESTROY)

init_cloudtrail: update_provider
	mkdir -p $(BUILD)/cloudtrail
	rsync -av $(RESOURCES)/terraforms/cloudtrail/ $(BUILD)/cloudtrail
	cd $(BUILD)/cloudtrail ; ln -sf ../*.tf .

show_cloudtrail:  
	cd $(BUILD)/cloudtrail; $(TF_SHOW) 

.PHONY: cloudtrail plan_cloudtrail plan_destroy_cloudtrail destroy_cloudtrail cloudtrail_only init_cloudtrail show_cloudtrail
