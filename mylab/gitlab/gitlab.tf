#
# Docker auto autoscale group configurations
#
resource "aws_autoscaling_group" "gmylab" {
  name = "docker-gmylab"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 1
  min_size = 1
  desired_capacity = 1
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.gmylab.name}"
  vpc_zone_identifier = ["${var.subnet_gmylab-us-west-2a}", "${var.subnet_gmylab-us-west-2b}","${var.subnet_gmylab-us-west-2c}"]

  tag {
    key = "Name"
    value = "gmylab"
    propagate_at_launch = true
  }
  tag {
    key = "${var.project_tags.key}"
    value = "${var.project_tags.value}"
    propagate_at_launch = true
  }
  # Workround to implement tagging for the time being: Tag: Key = mylab:billing Value = swsplatform
}

resource "aws_launch_configuration" "gmylab" {
  name = "docker-gmylab-v1"
  image_id = "${lookup(var.image_id, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile.gmylab}"
  security_groups = [ "${aws_security_group.gmylab.id}" ]
  key_name = "${var.aws_ec2_keypair.gmylab}"  
  #depends_on = ["aws_security_group.gmylab"]
  
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
  
  user_data = <<USER_DATA
${file("cloud-config/gmylab.yaml")}
${file("../common/cloud-config/systemd-units.yaml")}
${file("../common/cloud-config/files.yaml")}
USER_DATA
}

# Docker gmylab security group for public
resource "aws_security_group" "gmylab" {
  name = "docker-gmylab" 
  vpc_id = "${var.vpc_id}"
  #depends_on = ["aws_security_group.gmylab_elb"]

  # ssh from campus and from vpc
  description = "Allow SSH from camous, and vpc, allow 5000-9000 from vpc."
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_from_mylab_forsythe}", "${var.vpc_cidr}" ]
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
    Name = "gmylab_sg"
  }
}

output "sg-gmylab-id" {
    value = "${aws_security_group.gmylab.id}"
}
output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.gmylab.id}"
}
output "aws-launch-configuration-name" {
    value = "${aws_launch_configuration.gmylab.name}"
}
output "aws-autoscaling-group-id" {
    value = "${aws_autoscaling_group.gmylab.id}"
}
output "aws-autoscaling-group-name" {
    value = "${aws_autoscaling_group.gmylab.name}"
}
