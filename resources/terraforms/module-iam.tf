module "iam" {
    source = "../modules/iam"
    deployment_user = "deployment"
    aws_account_id = "${var.aws_account.id}"
    aws_account_region = "${var.aws_account.default_region}"
    cluster_name = "${var.cluster_name}"
    config-bucket = "${module.s3.s3_bucket_config_id}"
}
