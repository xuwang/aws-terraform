module "iam" {
    source = "../modules/iam"
    deployment_user = "deployment"
    aws_account_id = "${var.aws_account.id}"
    aws_account_user = "${var.aws_account.user}"
    cloudinit_file_path = "cloud-config/aws-files.yaml"
}
