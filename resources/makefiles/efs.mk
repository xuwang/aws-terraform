efs: plan_efs
	@echo "#### Working on $@"
	cd $(BUILD); $(TF_APPLY);

plan_efs: init_efs
	@echo "#### Working on $@"
	cd $(BUILD); $(TF_GET); $(TF_PLAN)

plan_destroy_efs:
	@echo "#### Working on $@"
	$(eval TMP := $(shell mktemp -d -t efs ))
	mv $(BUILD)/efs*.tf $(TMP)
	cd $(BUILD); $(TF_PLAN)
	mv  $(TMP)/efs*.tf $(BUILD)
	rmdir $(TMP)

destroy_efs: 
	@echo "#### Working on $@"
	rm -f $(BUILD)/efs*.tf
	cd $(BUILD); $(TF_APPLY)

init_efs: init_vpc
	cp -rf $(RESOURCES)/terraforms/efs.tf $(BUILD)

.PHONY: efs plan_destroy_efs destroy_efs plan_efs init_efs clean_efs
