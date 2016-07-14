module "etcd" {
  source = "../modules/cluster"

  # cluster varaiables
  cluster_name = "etcd"
  # a list of subnet IDs to launch resources in.
  cluster_vpc_zone_identifiers = "${module.etcd_subnet_a.id},${module.etcd_subnet_b.id},${module.etcd_subnet_c.id}"
  # for etcd, cluster_min_size = cluster_max_size = cluster_desired_capacity = <odd number>
  cluster_min_size = 1
  cluster_max_size = 1
  cluster_desired_capacity = 1
  cluster_security_groups = "${aws_security_group.etcd.id}"

  # Instance specifications
  ami = "${var.ami}"
  image_type = "t2.small"
  keypair = "${var.cluster_name}-etcd"

  # Note: currently etcd launch_configuration devices can NOT be changed after etcd cluster is up
  # See https://github.com/hashicorp/terraform/issues/2910
  # Instance disks
  root_volume_type = "gp2"
  root_volume_size = 12
  docker_volume_type = "gp2"
  docker_volume_size = 12 
  data_volume_type = "gp2"
  data_volume_size = 100

  user_data = "${file("cloud-config/s3-cloudconfig-bootstrap.sh")}"
  iam_role_policy = "${template_file.etcd_policy_json.rendered}"
}

# Upload CoreOS cloud-config to a s3 bucket; s3-cloudconfig-bootstrap script in user-data will download 
# the cloud-config upon reboot to configure the system. This avoids rebuilding machines when 
# changing cloud-config.
resource "aws_s3_bucket_object" "etcd_cloud_config" {
  bucket = "${aws_s3_bucket.cloudinit.id}"
  key = "etcd/cloud-config.yaml"
  content = "${template_file.etcd_cloud_config.rendered}"
}
resource "template_file" "etcd_cloud_config" {
    template = "${file("cloud-config/etcd.yaml.tmpl")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account.id}"
        "AWS_USER" = "${aws_iam_user.deployment.name}"
        "AWS_ACCESS_KEY_ID" = "${aws_iam_access_key.deployment.id}"
        "AWS_SECRET_ACCESS_KEY" = "${aws_iam_access_key.deployment.secret}"
        "AWS_DEFAULT_REGION" = "${var.aws_account.default_region}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}
resource "template_file" "etcd_policy_json" {
    template = "${file(\"policies/etcd_policy.json\")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account.id}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}
resource "aws_security_group" "etcd"  {
  name = "etcd"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  description = "etcd"
  depends_on = ["aws_s3_bucket_object.etcd_cloud_config"]
  lifecycle { create_before_destroy = true }

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow etcd peers to communicate, include etcd proxies
  ingress {
    from_port = 2380
    to_port = 2380
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.cluster_vpc.cidr_block}"]
  }

  # Allow etcd clients to communicate
  ingress {
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.cluster_vpc.cidr_block}"]
  }

  # Allow SSH from my hosts
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.allow_ssh_cidr)}"]
    self = true
  }

  tags {
    Name = "etcd"
  }
}



