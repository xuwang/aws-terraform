
Download from offical release.

https://dl.bintray.com/mitchellh/terraform/terraform_0.3.1_darwin_amd64.zip

Copy this to $HOME/bin/terraform && unzip terraform_0.3.1_darwin_amd64.zip

Make sure the PATH include $HOME/bin/terraform.

cd project/pacific-aws
source bin/alias.sh
tfplan
tfapply
terraform show terraform.tfstat
tfdestroyplan
terraform apply destroy.plan

Check status using aws command:

aws ec2 describe-instances --filters Name=tag-value,Values="docker-etcd-*"
