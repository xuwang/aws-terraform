#
# Docker auto autoscale group configurations
#
resource "aws_autoscaling_group" "core" {
  name = "docker-core"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 1
  min_size = 1
  desired_capacity = 1
  health_check_type = "EC2"
  force_delete = true
  # If first time build, use this:
  # launch_configuration = "${aws_launch_configuration.core.name}"
  # 
  # core-green is an update from the core-test: added more space
  #launch_configuration = "docker-core-blue"
  launch_configuration = "${aws_launch_configuration.core.name}"
  vpc_zone_identifier = ["${var.subnet_core-us-west-2a}", "${var.subnet_core-us-west-2b}","${var.subnet_core-us-west-2c}"]
  
  # Workround to implement tagging for the time being: Tag: Key = mylab:billing Value = swsplatform
  provisioner "local-exec" {
      command = <<CMD_DATA
aws --profile mylab autoscaling create-or-update-tags --tags \
ResourceId=${aws_autoscaling_group.core.id},\
ResourceType=auto-scaling-group,Key=Name,Value=core,PropagateAtLaunch=true \
ResourceId=${aws_autoscaling_group.core.id},\
ResourceType=auto-scaling-group,${var.project_tags.mylab},PropagateAtLaunch=true\
CMD_DATA
  }
}

resource "aws_launch_configuration" "core" {
  name = "docker-core-v1"
  image_id = "${lookup(var.image_id, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile.core}"
  security_groups = [ "${aws_security_group.core.id}" ]
  key_name = "${var.aws_ec2_keypair.core}"  
  #depends_on = ["aws_security_group.core"]
  
  user_data = <<USER_DATA
${file("cloud-config/core.yaml")}
${file("../common/cloud-config/systemd-units.yaml")}
${file("../common/cloud-config/files.yaml")}
USER_DATA
}

# Docker core security group for public
resource "aws_security_group" "core" {
  name = "docker-core" 
  vpc_id = "${var.vpc_id}"

  # ssh from vpc
  description = "Allow SSH from vpc."
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.vpc_cidr}" ]
  }
  
  ingress {
    from_port = 5000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = [ "${var.vpc_cidr}" ]
  }

  # For splunk logging
  ingress {
    from_port = 10514
    to_port = 10514
    protocol = "tcp"
    cidr_blocks = [ "${var.vpc_cidr}" ]
  }

  tags {
    Name = "core_sg"
  }
}

output "sg-core-id" {
    value = "${aws_security_group.core.id}"
}
output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.core.id}"
}
output "aws-launch-configuration-name" {
    value = "${aws_launch_configuration.core.name}"
}
output "aws-autoscaling-group-id" {
    value = "${aws_autoscaling_group.core.id}"
}
output "aws-autoscaling-group-name" {
    value = "${aws_autoscaling_group.core.name}"
}
