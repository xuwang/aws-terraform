#
# Docker hosting2 autoscale group configurations
#
resource "aws_autoscaling_group" "docker_hosting2" {
  name = "docker-hosting2"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  max_size = 9
  min_size = 2
  desired_capacity = 2
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.docker_hosting2.name}"
  vpc_zone_identifier = ["${var.subnet_hosting-us-west-2a}","${var.subnet_hosting-us-west-2b}","${var.subnet_hosting-us-west-2c}"]
  
  # Name tag
  tag {
    key = "Name"
    value = "docker-hosting2"
    propagate_at_launch = true
  }
  # Billing
  tag {
    key = "${var.project_tag_mylab.key}"
    value = "${var.project_tag_mylab.value}"
    propagate_at_launch = true
  }
}

output "aws-autoscaling-group-id" {
  value = "${aws_autoscaling_group.docker_hosting2.id}"
}

resource "aws_launch_configuration" "docker_hosting2" {
  name = "docker-hosting2-v2"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile.hosting}"
  security_groups = [ "${var.security_group_hosting}" ]
  key_name = "${var.aws_ec2_keypair.hosting}"  

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

  user_data = <<USER_DATA
${file("../../scripts/s3-cloudconfig-bootstrap.sh")}
USER_DATA
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
    value = "${aws_launch_configuration.docker_hosting2.id}"
}
