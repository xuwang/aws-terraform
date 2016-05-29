variable "aws_account_id" { }
variable "aws_account_region" { }
variable "deployment_user" { default = "deployment" }
variable "cloud_config_file_path" { default = "cloud-config/aws-files.yaml" }
variable "cluster_name" { default = "coreos-cluster" }
variable "config-bucket" { default = "coreos-cluster" }