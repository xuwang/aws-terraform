module "etcd" {
  source = "../modules/cluster"

  # cluster varaiables
  cluster_name = "etcd"
  # a list of subnet IDs to launch resources in.
  cluster_vpc_zone_identifiers = "${module.vpc.etcd_subnet_a_id},${module.vpc.etcd_subnet_b_id},${module.vpc.etcd_subnet_c_id}"
  # for etcd, cluster_min_size = cluster_max_size = cluster_desired_capacity = <odd number>
  cluster_min_size = 1
  cluster_max_size = 1
  cluster_desired_capacity = 1
  cluster_security_groups = "${aws_security_group.etcd.id}"

  # Instance specifications
  ami = "${var.ami}"
  image_type = "t2.small"
  keypair = "etcd"

  # Note: currently etcd launch_configuration devices can NOT be changed after etcd cluster is up
  # See https://github.com/hashicorp/terraform/issues/2910
  # Instance disks
  root_volume_type = "gp2"
  root_volume_size = 12
  docker_volume_type = "gp2"
  docker_volume_size = 12 
  data_volume_type = "gp2"
  data_volume_size = 100

  keypair = "etcd"
  user_data = "${file("cloud-config/s3-cloudconfig-bootstrap.sh")}"
  iam_role_policy = "${file(\"policies/etcd_policy.json\")}"
}

resource "aws_security_group" "etcd"  {
  name = "etcd"
  vpc_id = "${module.vpc.vpc_id}"
  description = "etcd"

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
    cidr_blocks = ["${module.vpc.vpc_cidr}"]
  }

  # Allow etcd clients to communicate
  ingress {
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr}"]
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

/*
resource "aws_s3_bucket_object" "cloudinit" {
  bucket = "${var.cloundinit-bucket}"
  key = "etcd2/cloud-config.yaml"
  source = "could-config/etcd.yaml"
}
*/


