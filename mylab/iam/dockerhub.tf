resource "aws_iam_instance_profile" "dockerhub" {
    name = "dockerhub"
    roles = ["${aws_iam_role.dockerhub.name}"]
}

resource "aws_iam_role" "dockerhub" {
    name = "dockerhub"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dockerhub_policy" {
    name = "dockerhub_policy"
    role = "${aws_iam_role.dockerhub.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::mylab-registry",
        "arn:aws:s3:::mylab-registry/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*"
      ],
      "Resource": [
        "arn:aws:s3:::012345678901-cloud-config/etcd/initial-cluster",
        "arn:aws:s3:::012345678901-cloud-config/dockerhub/",
        "arn:aws:s3:::012345678901-cloud-config/dockerhub/*",
        "arn:aws:s3:::mylab-config",
        "arn:aws:s3:::mylab-config/*"
      ]
    }
  ]
}
EOF
}
