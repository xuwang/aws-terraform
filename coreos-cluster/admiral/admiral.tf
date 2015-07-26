#
# Admiral auto autoscale group configurations
#
resource "aws_autoscaling_group" "admiral" {
  name = "docker-admiral"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  min_size = "${var.admiral_cluster_capacity.min_size}"
  max_size = "${var.admiral_cluster_capacity.max_size}"
  desired_capacity = "${var.admiral_cluster_capacity.desired_capacity}"
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.admiral.name}"
  vpc_zone_identifier = ["${var.subnet_admiral-us-west-2a}", "${var.subnet_admiral-us-west-2b}","${var.subnet_admiral-us-west-2c}"]

  tag {
    key = "Name"
    value = "admiral"
    propagate_at_launch = true
  }
  tag {
    key = "${var.project_tag_mylab.key}"
    value = "${var.project_tag_mylab.value}"
    propagate_at_launch = true
  }
  # Workround to implement tagging for the time being: Tag: Key = mylab:billing Value = swsplatform
}

resource "aws_launch_configuration" "admiral" {
  name = "docker-admiral"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type.admiral}"
  iam_instance_profile = "${var.iam_instance_profile.admiral}"
  security_groups = [ "${var.security_group_admiral}"]
  key_name = "${var.aws_ec2_keypair.admiral}" 
  
  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "24"
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "80"
  }
  # /opt/data
  ebs_block_device = {
    device_name = "/dev/sdc"
    volume_type = "gp2"
    volume_size = "120"
  }
  
  user_data = "${file("../../scripts/s3-cloudconfig-bootstrap.sh")}"
}

resource "aws_iam_instance_profile" "admiral" {
    name = "admiral"
    roles = ["${aws_iam_role.admiral.name}"]
}

resource "aws_iam_role" "admiral" {
    name = "admiral"
    path = "/"
    assume_role_policy = "${file(\"../tfcommon/assume_role_policy.json\")}"
}

resource "aws_iam_role_policy" "admiral_policy" {
    name = "admiral_policy"
    role = "${aws_iam_role.admiral.id}"
    policy = "${file(\"admiral_policy.json\")}"
}

output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.admiral.id}"
}
output "aws-launch-configuration-name" {
    value = "${aws_launch_configuration.admiral.name}"
}
output "aws-autoscaling-group-id" {
    value = "${aws_autoscaling_group.admiral.id}"
}
output "aws-autoscaling-group-name" {
    value = "${aws_autoscaling_group.admiral.name}"
}
