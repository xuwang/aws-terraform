
# deployment user for elb registrations, s3 access, efs mount etc.
resource "aws_iam_user" "deployment" {
    name = "${var.cluster_name}-deployment"
    path = "/system/"   
}
resource "aws_iam_user_policy" "deployment" {
    name = "${aws_iam_user.deployment.name}"
    user = "${aws_iam_user.deployment.name}"
    policy = "${file(\"../policies/deployment_policy.json\")}"
}

resource "aws_iam_policy_attachment" "efs-readonly" {
    name = "efs-readonly"
    users = ["${aws_iam_user.deployment.name}"]
    policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
}

# Save deployment credetials to config bucket
# TODO: add encryption
resource "aws_s3_bucket_object" "aws_deployment_id" {
    bucket = "${var.s3_config_bucket}"
    key = "credentials/deployment/id"
    content = "${aws_iam_access_key.deployment.id}"
}

resource "aws_s3_bucket_object" "aws_deployment_key" {
    bucket = "${var.s3_config_bucket}"
    key = "credentials/deployment/key"
    content = "${aws_iam_access_key.deployment.secret}"
}

resource "aws_iam_access_key" "deployment" {
    user = "${aws_iam_user.deployment.name}"
}

output "deployment_user" { value = "${aws_iam_user.deployment.name}" }
output "deployment_key_id" { value = "${aws_iam_access_key.deployment.id}" }
output "deployment_key_secret" { value = "${aws_iam_access_key.deployment.secret}" }