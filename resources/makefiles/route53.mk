route53: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_GET); \
	$(TF_APPLY) -target module.route53

destroy_route53: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_DESTROY) -target module.route53; \
	rm -f $(CONFIG)/aws-file.yaml

plan_route53: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_GET); \
	$(TF_PLAN) -target module.route53;

refresh_route53: | $(TF_PORVIDER)
	cd $(BUILD); \
	$(TF_REFRESH) -target module.route53

.PHONY: route53 destroy_route53 refresh_route53 play_route53

