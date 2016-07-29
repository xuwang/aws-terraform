#
#  General cluster autoscale group configurations
#
resource "aws_autoscaling_group" "cluster" {
  vpc_zone_identifier = ["${split(",",var.cluster_vpc_zone_identifiers)}"]
  name = "${var.cluster_name}-${var.asg_name}"
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"
  
  health_check_type = "EC2"
  health_check_grace_period = 300
  force_delete = true
  metrics_granularity = "1Minute"

  launch_configuration = "${aws_launch_configuration.cluster.name}"
  
  tag {
    key = "Name"
    value = "${var.cluster_name}-${var.asg_name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "cluster" {
  # use system generated name to allow changes of launch_configuration
  name_prefix = "${var.cluster_name}-${var.asg_name}-"
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.cluster.name}"
  security_groups = ["${split(",",var.cluster_security_groups)}"]
  key_name = "${var.keypair}"  
  lifecycle { create_before_destroy = true }

  # /root
  root_block_device = {
    volume_type = "${var.root_volume_type}" 
    volume_size = "${var.root_volume_size}" 
  }

  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "${var.docker_volume_type}" 
    volume_size = "${var.docker_volume_size}" 
  }

  # /opt/data
  ebs_block_device = {
    device_name = "/dev/sdc"
    volume_type = "${var.data_volume_type}"
    volume_size = "${var.data_volume_size}"
  }

  # instance store device, necessary for instance with ephemeral devices, e.g. m3.
  # no effect for instances without ephemeral disks. 
  ephemeral_block_device  {
    device_name = "/dev/sdd"
    virtual_name = "ephemeral0"
  }

  # cluser user_data
  user_data = "${var.user_data}"
}

# Define policy and role
resource "aws_iam_role_policy" "cluster" {
  name = "${var.asg_name}"
  role = "${aws_iam_role.cluster.id}"
  policy = "${var.iam_role_policy}"
  lifecycle { create_before_destroy = true }
}

# setup the cluster ec2 profile
resource "aws_iam_instance_profile" "cluster" {
  name = "${var.asg_name}"
  roles = ["${aws_iam_role.cluster.name}"]
  lifecycle { create_before_destroy = true }

  # Sleep a little to wait the IAM profile to be ready - 
  # This seems to fix:
  #     aws_launch_configuration.cluster: Error creating launch configuration: ValidationError: You are not authorized to #       perform this operation
  provisioner "local-exec" {
    command = "sleep ${var.wait_time}"
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.asg_name}"
  path = "/"
  lifecycle { create_before_destroy = true }
  assume_role_policy =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
