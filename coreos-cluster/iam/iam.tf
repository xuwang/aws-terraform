resource "aws_iam_access_key" "deployment" {
    user = "${aws_iam_user.deployment.name}"
}

resource "aws_iam_user" "deployment" {
    name = "deployment"
    path = "/system/"
}

resource "aws_iam_user_policy" "deployment" {
    name = "deployment"
    user = "${aws_iam_user.deployment.name}"
    policy = "${file(\"deployment_policy.json\")}"
}

output "deployment_user_id" {
    value = "${aws_iam_access_key.deployment.id}"
}

output "deployment_user_name" {
    value = "${aws_iam_access_key.deployment.user}"
}

output "deployment_user_secret" {
    value = "${aws_iam_access_key.deployment.secret}"
}
