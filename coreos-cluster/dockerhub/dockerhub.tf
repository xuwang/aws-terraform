#
# Dockerhub auto autoscale group configurations
#
resource "aws_autoscaling_group" "dockerhub" {
  name = "dockerhub"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  min_size = "${var.dockerhub_cluster_capacity.min_size}"
  max_size = "${var.dockerhub_cluster_capacity.max_size}"
  desired_capacity = "${var.dockerhub_cluster_capacity.desired_capacity}"
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.dockerhub.name}"
  vpc_zone_identifier = ["${var.subnet_admiral-us-west-2a}", "${var.subnet_admiral-us-west-2b}","${var.subnet_admiral-us-west-2c}"]
  
  tag {
    key = "Name"
    value = "dockerhub"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "dockerhub" {
  name = "docker-dockerhub2"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type.dockerhub}"
  iam_instance_profile = "${var.iam_instance_profile.dockerhub}"
  security_groups = [ "${var.security_group_dockerhub}"]
  key_name = "${var.aws_ec2_keypair.dockerhub}"
  
  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "24"
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "50"
  }
  
  user_data = "${file("../../scripts/s3-cloudconfig-bootstrap.sh")}"
}

resource "aws_iam_instance_profile" "dockerhub" {
    name = "dockerhub"
    roles = ["${aws_iam_role.dockerhub.name}"]
}

resource "aws_iam_role" "dockerhub" {
    name = "dockerhub"
    path = "/"
    assume_role_policy =  "${file(\"../tfcommon/assume_role_policy.json\")}"
}

resource "aws_iam_role_policy" "dockerhub_policy" {
    name = "dockerhub_policy"
    role = "${aws_iam_role.dockerhub.id}"
  
output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.dockerhub2.id}"
}
output "aws-launch-configuration-name" {
    value = "${aws_launch_configuration.dockerhub2.name}"
}
output "aws-autoscaling-group-id" {
    value = "${aws_autoscaling_group.dockerhub2.id}"
}
output "aws-autoscaling-group-name" {
    value = "${aws_autoscaling_group.dockerhub2.name}"
}
