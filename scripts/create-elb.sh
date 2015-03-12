aws iam create-role --role-name hosting --assume-role-policy-document file://ec2-role-trust-policy.json
aws iam put-role-policy --role-name hosting  --policy-name S3-Hosting  --policy-document file://s3-hosting-policy.json
aws iam create-instance-profile --instance-profile-name hosting
aws iam add-role-to-instance-profile --instance-profile-name hosting --role-name hosting