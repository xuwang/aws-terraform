#
# etcd cluster autoscale group configurations
#
resource "aws_autoscaling_group" "etcd" {
  name = "etcd"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  min_size = 3
  max_size = 3
  desired_capacity = 3
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.etcd.name}"
  vpc_zone_identifier = ["${var.subnet_etcd-us-west-2a}","${var.subnet_etcd-us-west-2b}","${var.subnet_etcd-us-west-2c}"]
  
  tag {
    key = "Name"
    value = "etcd"
    propagate_at_launch = true
  }
  # Billing
  tag {
    key = "Billing"
    value = "${var.project_tags.coreos-cluster}"
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

  user_data = <<USER_DATA
${file("../common/cloud-config2/etcd-aws-cluster.yaml")}
${file("../common/cloud-config2/systemd-units.yaml")}
${file("../common/cloud-config2/files.yaml")}
${file("../common/cloud-config2/etcd-peers-init.yaml")}
USER_DATA
}

output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.etcd.id}"
}

