#
# Docker worker autoscale group configurations
#
resource "aws_autoscaling_group" "worker" {
  name = "worker"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  min_size = "${var.worker_cluster_capacity.min_size}"
  max_size = "${var.worker_cluster_capacity.max_size}"
  desired_capacity = "${var.worker_cluster_capacity.desired_capacity}"
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.worker.name}"
  vpc_zone_identifier = ["${var.subnet_worker-us-west-2a}","${var.subnet_worker-us-west-2b}","${var.subnet_worker-us-west-2c}"]
  
  # Name tag
  tag {
    key = "Name"
    value = "worker"
    propagate_at_launch = true
  }
}

output "aws-autoscaling-group-id" {
  value = "${aws_autoscaling_group.worker.id}"
}

resource "aws_launch_configuration" "worker" {
  name = "worker"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile.worker}"
  security_groups = [ "${var.security_group_worker}" ]
  key_name = "${var.aws_ec2_keypair.worker}"
  lifecycle { create_before_destroy = true }

  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "12"
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "50"
  }

  user_data = "${file("../tfcommon/cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

resource "aws_iam_instance_profile" "worker" {
    name = "worker"
    roles = ["${aws_iam_role.worker.name}"]
}

resource "aws_iam_role" "worker" {
    name = "worker"
    path = "/"
    assume_role_policy =  "${file(\"../tfcommon/assume_role_policy.json\")}"
}

resource "aws_iam_role_policy" "worker_policy" {
    name = "worker_policy"
    role = "${aws_iam_role.worker.id}"
    policy = "${file(\"worker_policy.json\")}"
}


output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.worker.id}"
}
