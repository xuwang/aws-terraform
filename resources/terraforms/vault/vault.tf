
module "vault" {
  source = "../../modules/asg-with-elb"

  # cluster varaiables
  asg_name = "vault"
  cluster_name = "${var.cluster_name}"
  # a list of subnet IDs to launch resources in.
  cluster_vpc_zone_identifiers = "${var.vault_subnet_0_id},${var.vault_subnet_1_id},${var.vault_subnet_2_id}"
  # for vault, cluster_min_size = cluster_max_size = cluster_desired_capacity = <odd number>
  cluster_min_size = 3
  cluster_max_size = 3
  cluster_desired_capacity = 3
  cluster_security_groups = "${aws_security_group.vault.id}"
  load_balancers = "${aws_elb.vault.id}"

  # Instance specifications
  ami = "${var.ami}"
  image_type = "m3.medium"
  keypair = "${var.cluster_name}-vault"

  # Note: currently vault launch_configuration devices can NOT be changed after vault cluster is up
  # See https://github.com/hashicorp/terraform/issues/2910
  # Instance disks
  root_volume_type = "gp2"
  root_volume_size = 12
  docker_volume_type = "gp2"
  docker_volume_size = 12 
  data_volume_type = "gp2"
  data_volume_size = 100

  user_data = "${file("../cloud-config/s3-cloudconfig-bootstrap.sh")}"
  iam_role_policy = "${data.template_file.vault_policy_json.rendered}"
}

# Upload CoreOS cloud-config to a s3 bucket; s3-cloudconfig-bootstrap script in user-data will download 
# the cloud-config upon reboot to configure the system. This avoids rebuilding machines when 
# changing cloud-config.
resource "aws_s3_bucket_object" "vault_cloud_config" {
  bucket = "${var.s3_cloudinit_bucket}"
  key = "vault/cloud-config.yaml"
  content = "${data.template_file.vault_cloud_config.rendered}"
}

data "template_file" "vault_cloud_config" {
    template = "${file("../cloud-config/vault.yaml.tmpl")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account["id"]}"
        "AWS_USER" = "${var.deployment_user}"
        "AWS_ACCESS_KEY_ID" = "${var.deployment_key_id}"
        "AWS_SECRET_ACCESS_KEY" = "${var.deployment_key_secret}"
        "AWS_DEFAULT_REGION" = "${var.aws_account["default_region"]}"
        "CLUSTER_NAME" = "${var.cluster_name}"
        "APP_REPOSITORY" = "${var.app_repository}"
        "GIT_SSH_COMMAND" = "\"${var.git_ssh_command}\""
        "VAULT_RELEASE_URL" = "${var.vault_release_url}"
  }
}

data "template_file" "vault_policy_json_test" {
    template = "${file("../policies/vault_policy.json")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account["id"]}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}

data "template_file" "vault_policy_json" {
    template = "${file("../policies/vault_policy.json")}"
    vars {
        "AWS_ACCOUNT" = "${var.aws_account["id"]}"
        "CLUSTER_NAME" = "${var.cluster_name}"
    }
}

// Security group for Vault allows SSH and HTTP access (via "tcp" in
// case TLS is used)
resource "aws_security_group" "vault" {
    name = "vault"
    description = "Vault servers"
    vpc_id = "${var.cluster_vpc_id}"
    tags {
        Name = "${var.cluster_name}-vault"
    }
}

resource "aws_security_group_rule" "vault-ssh" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.allow_ssh_cidr)}"]
}

# Allow etcd client to communicate
resource "aws_security_group_rule" "vault-etcd" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "ingress"
    from_port = 2380
    to_port = 2380
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
}

# Allow etcd peers to communicate
resource "aws_security_group_rule" "vault-etcd-peer" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "ingress"
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_vpc_cidr}"]
}

// This rule allows Vault HTTP API access to individual nodes, since each will
// need to be addressed individually for unsealing.
resource "aws_security_group_rule" "vault-http-api" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "ingress"
    from_port = 8200
    to_port = 8200
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault-egress" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

output "vault_security_group" { value = "${aws_security_group.vault.id}" }
