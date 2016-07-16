module "worker" {
  source = "../../modules/cluster"

  # cluster varaiables
  cluster_name = "worker"
  # a list of subnet IDs to launch resources in.
  cluster_vpc_zone_identifiers = "${var.worker_subnet_a_id},${var.worker_subnet_b_id},${var.worker_subnet_c_id}"
  cluster_min_size = 1
  cluster_max_size = 1
  cluster_desired_capacity = 1
  cluster_security_groups = "${aws_security_group.worker.id}"

  # Instance specifications
  ami = "${var.ami}"
  image_type = "t2.small"
  keypair = "${var.cluster_name}-worker"

  # Note: currently worker launch_configuration devices can NOT be changed after worker cluster is up
  # See https://github.com/hashicorp/terraform/issues/2910
  # Instance disks
  root_volume_type = "gp2"
  root_volume_size = 12
  docker_volume_type = "gp2"
  docker_volume_size = 12 
  data_volume_type = "gp2"
  data_volume_size = 100

  user_data = "${file("../cloud-config/s3-cloudconfig-bootstrap.sh")}"
  iam_role_policy = "${template_file.worker_policy_json.rendered}"
}

# Upload CoreOS cloud-config to a s3 bucket; s3-cloudconfig-bootstrap script in user-data will download 
# the cloud-config upon reboot to configure the system. This avoids rebuilding machines when 
# changing cloud-config.
resource "aws_s3_bucket_object" "worker_cloud_config" {
  bucket = "${s3_cloudinit_bucket}"
  key = "worker/cloud-config.yaml"
  content = "${template_file.worker_cloud_config.rendered}"
}

resource "template_file" "worker_cloud_config" {
    template = "${file("../cloud-config/worker.yaml.tmpl")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account.id}"
        "AWS_USER" = "${var.deployment_user}"
        "AWS_ACCESS_KEY_ID" = "${var.deployment_key_id}"
        "AWS_SECRET_ACCESS_KEY" = "${var.deployment_key_secret}"
        "AWS_DEFAULT_REGION" = "${var.aws_account.default_region}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}

resource "template_file" "worker_policy_json" {
    template = "${file(\"../policies/worker_policy.json\")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account.id}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}

resource "aws_security_group" "worker"  {
  name = "worker"
  vpc_id = "${var.cluster_vpc_id}"
  description = "worker"

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow access from vpc
  ingress {
    from_port = 10
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
  }

  # Allow access from vpc
  ingress {
    from_port = 10
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
  }

  # Allow SSH from my hosts
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
    self = true
  }

  tags {
    Name = "worker"
  }
}

output "worker_security_group" { value = "${aws_security_group.worker.id}" }

