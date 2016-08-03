module "etcd" {
  source = "../../modules/cluster"

  # cluster varaiables
  asg_name = "etcd"
  cluster_name = "${var.cluster_name}"
  # a list of subnet IDs to launch resources in.
  cluster_vpc_zone_identifiers = "${var.etcd_subnet_a_id},${var.etcd_subnet_b_id},${var.etcd_subnet_c_id}"
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

  user_data = "${file("../cloud-config/s3-cloudconfig-bootstrap.sh")}"
  iam_role_policy = "${template_file.etcd_policy_json.rendered}"
}

# Upload CoreOS cloud-config to a s3 bucket; s3-cloudconfig-bootstrap script in user-data will download 
# the cloud-config upon reboot to configure the system. This avoids rebuilding machines when 
# changing cloud-config.
resource "aws_s3_bucket_object" "etcd_cloud_config" {
  bucket = "${var.s3_cloudinit_bucket}"
  key = "etcd/cloud-config.yaml"
  content = "${template_file.etcd_cloud_config.rendered}"
}

resource "template_file" "etcd_cloud_config" {
    template = "${file("../cloud-config/etcd.yaml.tmpl")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account.id}"
        "AWS_USER" = "${var.deployment_user}"
        "AWS_ACCESS_KEY_ID" = "${var.deployment_key_id}"
        "AWS_SECRET_ACCESS_KEY" = "${var.deployment_key_secret}"
        "AWS_DEFAULT_REGION" = "${var.aws_account.default_region}"
        "CLUSTER_NAME" = "${var.cluster_name}"
        "APP_REPOSITORY" = "${var.app_repository}"
        "GIT_SSH_COMMAND" = "\"${var.git_ssh_command}\""
    }
}

resource "template_file" "etcd_policy_json" {
    template = "${file(\"../policies/etcd_policy.json\")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account.id}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}

resource "aws_security_group" "etcd"  {
  name = "${var.cluster_name}-etcd"
  vpc_id = "${var.cluster_vpc_id}"
  description = "etcd"
  # Hacker's note: the cloud_config has to be uploaded to s3 before instances fireup
  # but module can't have 'depends_on', so we have to make 
  # this indrect dependency through security group
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
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
  }

  # Allow etcd clients to communicate
  ingress {
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
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
    Name = "${var.cluster_name}-etcd"
  }
}

output "etcd_security_group" { value = "${aws_security_group.etcd.id}" }
