resource "aws_iam_instance_profile" "admiral" {
    name = "admiral"
    roles = ["${aws_iam_role.admiral.name}"]
}

resource "aws_iam_role" "admiral" {
    name = "admiral"
    path = "/"
    assume_role_policy = "${file(\"assume_role_policy.json\")}"
}

resource "aws_iam_role_policy" "admiral_policy" {
    name = "admiral_policy"
    role = "${aws_iam_role.admiral.id}"
    policy = "${file(\"admiral_policy.json\")}"
}
