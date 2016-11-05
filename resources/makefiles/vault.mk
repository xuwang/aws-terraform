vault: init_vault 
	@cd $(BUILD)/$@ ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for vpc/subnets to be ready
	sleep 5
	#@cd $(BUILD)/$@; $(TF_OUTPUT) && @$(MAKE) gen_vault_vars
	$(MAKE) get_vault_ips

vault_only: init create_vault_key
	mkdir -p $(BUILD)/vault
	rsync -av  $(RESOURCES)/terraforms/vault/ $(BUILD)/vault
	cd $(BUILD)/vault ; ln -sf ../*.tf .
	@if [[ "X$(APP_REPOSITORY_DEPLOYKEY)" != "X" ]] && [[ -f $(APP_REPOSITORY_DEPLOYKEY) ]]; then \
  		 cat $(APP_REPOSITORY_DEPLOYKEY) >> $(BUILD)/cloud-config/vault.yaml.tmpl; \
  	fi
	cat $(RESOURCES)/cloud-config/common-files.yaml.tmpl >> $(BUILD)/cloud-config/vault.yaml.tmpl
	@cd $(BUILD)/vault ; $(SCRIPTS)/tf-apply-confirm.sh
	# Wait for vpc/subnets to be ready
	sleep 5
	@$(MAKE) gen_vault_vars
	$(MAKE) get_vault_ips

plan_vault: init_vault
	cd $(BUILD)/vault; $(TF_GET); $(TF_PLAN)

destroy_vault: destroy_vault_key 
	cd $(BUILD)/vault; $(TF_DESTROY)

show_vault:  
	cd $(BUILD)/vault; $(TF_SHOW) 

create_vault_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c $(CLUSTER_NAME)-vault;

upload_vault_key:
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -u $(CLUSTER_NAME)-vault;

destroy_vault_key:
	cd $(BUILD); $(SCRIPTS)/aws-keypair.sh -d $(CLUSTER_NAME)-vault;

init_vault: vpc iam s3 create_vault_key $(SITE_CERT)
	mkdir -p $(BUILD)/vault
	rsync -av  $(RESOURCES)/terraforms/vault/ $(BUILD)/vault
	cd $(BUILD)/vault ; ln -sf ../*.tf .
	@if [[ "X$(APP_REPOSITORY_DEPLOYKEY)" != "X" ]] && [[ -f $(APP_REPOSITORY_DEPLOYKEY) ]]; then \
  		 cat $(APP_REPOSITORY_DEPLOYKEY) >> $(BUILD)/cloud-config/vault.yaml.tmpl; \
  	fi
	cat $(RESOURCES)/cloud-config/common-files.yaml.tmpl >> $(BUILD)/cloud-config/vault.yaml.tmpl

clean_vault:
	rm -rf $(BUILD)/vault; $(BUILD)/vault_vars.tf

gen_vault_vars:
	cd $(BUILD)/vault; ${SCRIPTS}/gen-tf-vars.sh > $(BUILD)/vault_vars.tf

get_vault_ips:
	@echo "vault public ips: " `$(SCRIPTS)/get-ec2-public-id.sh $(CLUSTER_NAME)-vault`

# Call this explicitly to re-load user_data
update_vault_user_data:
	cat $(RESOURCES)/cloud-config/vault.yaml.tmpl $(RESOURCES)/cloud-config/common-files.yaml.tmpl > $(BUILD)/cloud-config/vault.yaml.tmpl
	cd $(BUILD)/vault; \
		$(TF_DESTROY) -target data.template_file.vault_cloud_config ; \
		$(TF_DESTROY) -target aws_s3_bucket_object.vault_cloud_config ; \
		$(TF_APPLY)

.PHONY: vault vault-only destroy_vault plan_destroy_vault plan_vault init_vault get_vault_ips update_vault_user_data
.PHONY: show_vault create_vault_key destroy_vault_key gen_vault_vars clean_vault
