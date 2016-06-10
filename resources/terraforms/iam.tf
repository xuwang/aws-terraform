variable "deployment_user" {
	default = "deployment"
}

variable "cloud_config_file_path" {
	default = "cloud-config/aws-files.yaml"
}

# deployment user for elb registrations etc.
resource "aws_iam_user" "deployment" {
    name = "${var.deployment_user}"
    path = "/system/"
}
resource "aws_iam_user_policy" "deployment" {
    name = "deployment"
    user = "${aws_iam_user.deployment.name}"
    policy = "${file(\"policies/deployment_policy.json\")}"
}

# Save deployment credetials to config bucket
# TODO: add encryption
resource "aws_s3_bucket_object" "aws_deployment_id" {
    bucket = "${aws_s3_bucket.config.id}"
    key = "credentials/deployment/id"
    content = "${aws_iam_access_key.deployment.id}"
}

resource "aws_s3_bucket_object" "aws_deployment_key" {
    bucket = "${aws_s3_bucket.config.id}"
    key = "credentials/deployment/key"
    content = "${aws_iam_access_key.deployment.secret}"
}

resource "aws_iam_access_key" "deployment" {
    user = "${aws_iam_user.deployment.name}"
}
