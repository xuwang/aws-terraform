module "cloudtrail" {
  source = "../../modules/cloudtrail"

  trail_name = "${var.cluster_name}"
  s3_bucket_name = "${var.aws_account["id"]}-${var.cluster_name}-cloudtrail"
  include_global_service_events = true
  is_multi_region_trail = true
  cluster_name = "${var.cluster_name}"
  aws_account_id = "${var.aws_account["id"]}"
}

