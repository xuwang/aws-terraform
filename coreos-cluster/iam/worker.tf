resource "aws_iam_instance_profile" "worker" {
    name = "worker"
    roles = ["${aws_iam_role.worker.name}"]
}

resource "aws_iam_role" "worker" {
    name = "worker"
    path = "/"
    assume_role_policy = 
    assume_role_policy =  "${file('assume_role_policy.json')}"

resource "aws_iam_role_policy" "worker_policy" {
    name = "worker_policy"
    role = "${aws_iam_role.worker.id}"
    policy = "${file('worker_policy.json')}"
}
