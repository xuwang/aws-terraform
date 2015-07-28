# Create build dir and copy tfcommon to build
$(BUILD):
	mkdir -p $(BUILD)
	cp -rf $(RESOURCES)/cloud-config $(BUILD)
	cp -rf $(RESOURCES)/certs $(BUILD)

$(TF_PORVIDER): | $(BUILD)
	# Generate aws key files
	$(SCRIPTS)/gen-provider.sh > $(TF_PORVIDER)

$(AMI_VARS): | $(BUILD)
	# Generate default AMI ids
	$(SCRIPTS)/get-ami.sh >> $(AMI_VARS)

init: 
	rm -f $(TF_PORVIDER) $(AMI_VARS)

show: | $(BUILD)
	cd $(BUILD); $(TF_SHOW)

show_state: | $(BUILD)
	cat $(BUILD)/terraform.tfstate

graph: | $(BUILD)
	cd $(BUILD); $(TF_GRAPH)

.PHONY: all init show show_state graph destroy refresh $(BUILD) $(KEY_VARS) $(AMI_VARS)
