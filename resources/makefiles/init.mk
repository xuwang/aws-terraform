# Create build dir and copy resources 
init: |
	mkdir -p $(BUILD)
	cp -rf $(RESOURCES)/cloud-config $(BUILD)
	cp -rf $(RESOURCES)/certs $(BUILD)
	cp -rf $(RESOURCES)/terraforms/module* $(BUILD)
	# Generate aws key files
	$(SCRIPTS)/gen-provider.sh > $(TF_PORVIDER)

$(TF_PORVIDER): | $(BUILD)
	# Generate aws key files
	$(SCRIPTS)/gen-provider.sh > $(TF_PORVIDER)

$(AMI_VARS): | $(BUILD)
	# Generate default AMI ids
	$(SCRIPTS)/get-ami.sh >> $(AMI_VARS)

show: | $(BUILD)
	cd $(BUILD); $(TF_SHOW)

show_state: | $(BUILD)
	cat $(BUILD)/terraform.tfstate

graph: | $(BUILD)
	cd $(BUILD); $(TF_GRAPH)

refresh: | $(BUILD)
	cd $(BUILD); $(TF_REFRESH)

$(BUILD): init

.PHONY: init show show_state graph refresh
