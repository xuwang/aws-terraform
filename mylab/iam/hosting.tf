resource "aws_iam_instance_profile" "hosting" {
    name = "hosting"
    roles = ["${aws_iam_role.hosting.name}"]
}

resource "aws_iam_role" "hosting" {
    name = "hosting"
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

resource "aws_iam_role_policy" "hosting_policy" {
    name = "hosting_policy"
    role = "${aws_iam_role.hosting.id}"
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
        "arn:aws:s3:::mylab-hosting",
        "arn:aws:s3:::mylab-hosting/*"
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
        "arn:aws:s3:::012345678901-cloud-config/hosting/",
        "arn:aws:s3:::012345678901-cloud-config/hosting/*",
        "arn:aws:s3:::files-itsappsup-example.com",
        "arn:aws:s3:::files-itsappsup-example.com/*"
      ]
    }
  ]
}
EOF
}
