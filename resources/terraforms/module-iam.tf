module "iam" {
    source = "../modules/iam"
    deployment_user = "deployment"
    aws_account_id = "${var.aws_account.id}"
    aws_account_user = "${var.aws_account.user}"
    aws_account_region = "${var.aws_account.default_region}"
    cluster_name = "${var.cluster_name}"
}
