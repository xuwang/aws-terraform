
# Cloudtrail default variables
variable "trail_name" { }
variable "s3_bucket_name" { }
variable "is_multi_region_trail" { default = false }
variable "include_global_service_events" { default = false }
variable "cluster_name" {}
variable "aws_account_id" {}
