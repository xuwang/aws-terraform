resource "aws_iam_instance_profile" "admiral" {
    name = "admiral"
    roles = ["${aws_iam_role.admiral.name}"]
}

resource "aws_iam_role" "admiral" {
    name = "admiral"
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

resource "aws_iam_role_policy" "admiral_policy" {
    name = "admiral_policy"
    role = "${aws_iam_role.admiral.id}"
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
        "arn:aws:s3:::mylab-config",
        "arn:aws:s3:::mylab-config/*",
        "arn:aws:s3:::mylab-registry",
        "arn:aws:s3:::mylab-registry/*",
        "arn:aws:s3:::mylab-jenkins",
        "arn:aws:s3:::mylab-jenkins/*",
        "arn:aws:s3:::mylab-splunk",
        "arn:aws:s3:::mylab-splunk/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "autoscaling:Describe*"
      ],
      "Resource": [
        "*"
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
        "arn:aws:s3:::012345678901-cloud-config/admiral/",
        "arn:aws:s3:::012345678901-cloud-config/admiral/*"
      ]
    }
  ]
}
EOF
}
