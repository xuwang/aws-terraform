#
# etcd cluster autoscale group configurations
#
resource "aws_autoscaling_group" "etcd" {
  name = "etcd"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  min_size = "${var.etcd_cluster_capacity.min_size}"
  max_size = "${var.etcd_cluster_capacity.max_size}"
  desired_capacity = "${var.etcd_cluster_capacity.desired_capacity}"
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.etcd.name}"
  vpc_zone_identifier = ["${var.subnet_etcd-us-west-2a}","${var.subnet_etcd-us-west-2b}","${var.subnet_etcd-us-west-2c}"]
  
  tag {
    key = "Name"
    value = "etcd"
    propagate_at_launch = true
  }
}

output "aws-autoscaling-group-id" {
  value = "${aws_autoscaling_group.etcd.id}"
}

resource "aws_launch_configuration" "etcd" {
  name = "etcd"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile.etcd}"
  security_groups = [ "${var.security_group_etcd}" ]
  key_name = "${var.aws_ec2_keypair.etcd}"  
  lifecycle { create_before_destroy = true }

  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "8"
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "8"
  }
  
  user_data = "${file("../tfcommon/cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

# setup the etcd ec2 profile, role and polices
resource "aws_iam_instance_profile" "etcd" {
    name = "etcd"
    roles = ["${aws_iam_role.etcd.name}"]
}

resource "aws_iam_role" "etcd" {
    name = "etcd"
    path = "/"
    assume_role_policy =  "${file(\"../tfcommon/assume_role_policy.json\")}"
}

resource "aws_iam_role_policy" "etcd_policy" {
    name = "etcd_policy"
    role = "${aws_iam_role.etcd.id}"
    policy = "${file(\"./etcd_policy.json\")}"
}

output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.etcd.id}"
}

