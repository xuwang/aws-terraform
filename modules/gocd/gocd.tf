#
# gocd autoscale group configurations
#
resource "aws_autoscaling_group" "gocd" {
  name = "gocd"
  # This placeholder will be replaced by array of variables defined for availability zone in the module's variables
  availability_zones = [ "${var.gocd_subnet_az_a}", "${var.gocd_subnet_az_b}" ]
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"

  health_check_type = "EC2"
  force_delete = true

  launch_configuration = "${aws_launch_configuration.gocd.name}"
  # This placeholder will be replaced by array of variables defined for VPC zone IDs in the module's variables
  vpc_zone_identifier = [ "${var.gocd_subnet_a_id}", "${var.gocd_subnet_b_id}" ]

  tag {
    key = "Name"
    value = "gocd"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "gocd" {
  # use system generated name to allow changes of launch_configuration
  # name = "workder-${var.ami}"
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.gocd.name}"
  security_groups = [ "${aws_security_group.gocd.id}" ]
  key_name = "${var.keypair}"
  lifecycle { create_before_destroy = true }

  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "${var.docker_volume_size}"
  }

  user_data = "${file("cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

resource "aws_iam_instance_profile" "gocd" {
    name = "gocd"
    roles = ["${aws_iam_role.gocd.name}"]
}

resource "aws_iam_role_policy" "gocd_policy" {
    name = "gocd"
    role = "${aws_iam_role.gocd.id}"
    policy = "${file(\"policies/gocd_policy.json\")}"
}

resource "aws_iam_role" "gocd" {
    name = "${var.cluster_name}_gocd"
    path = "/"
    assume_role_policy =  "${file(\"policies/assume_role_policy.json\")}"
}
