#
# Docker auto autoscale group configurations
#
resource "aws_autoscaling_group" "dockerhub2" {
  name = "dockerhub2"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 2
  min_size = 1
  desired_capacity = 2
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.dockerhub2.name}"
  vpc_zone_identifier = ["${var.subnet_admiral-us-west-2a}", "${var.subnet_admiral-us-west-2b}","${var.subnet_admiral-us-west-2c}"]
  
  tag {
    key = "Name"
    value = "dockerhub2"
    propagate_at_launch = true
  }
  tag {
    key = "${var.project_tag_mylab.key}"
    value = "${var.project_tag_mylab.value}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "dockerhub2" {
  name = "docker-dockerhub2-v2"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
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
  
  
  user_data = <<USER_DATA
${file("../../scripts/s3-cloudconfig-bootstrap.sh")}
USER_DATA
}

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
