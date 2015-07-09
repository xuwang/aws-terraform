resource "aws_iam_instance_profile" "dockerhub" {
    name = "dockerhub"
    roles = ["${aws_iam_role.dockerhub.name}"]
}

resource "aws_iam_role" "dockerhub" {
    name = "dockerhub"
    path = "/"
    assume_role_policy =  "${file('assume_role_policy.json')}"
}

resource "aws_iam_role_policy" "dockerhub_policy" {
    name = "dockerhub_policy"
    role = "${aws_iam_role.dockerhub.id}"
    policy = "${file('dockerhub_policy.json')}"
EOF
}
