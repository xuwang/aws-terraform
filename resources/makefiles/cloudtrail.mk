cloudtrail:
	@echo Setup CloudTrail for all supported regions, CloudTrail SNS topics, and a SQS that subscripts CloudTrail SNS topics
	$(SCRIPTS)/cloudtrail-admin.sh -p $(AWS_PROFILE) -a create -r $(AWS_REGION) -y

cloudtrail_info:
	$(SCRIPTS)/cloudtrail-admin.sh -p $(AWS_PROFILE) -a show -r $(AWS_REGION) -y 

destroy_cloudtrail:
	$(SCRIPTS)/cloudtrail-admin.sh -p $(AWS_PROFILE) -a delete -r $(AWS_REGION) -y

clean_cloudtrail: destroy_cloudtrail

.PHONY: cloudtrail destroy_cloudtrail clean_cloudtrail