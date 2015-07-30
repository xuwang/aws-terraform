#
# etcd cluster autoscale group configurations
#
resource "aws_autoscaling_group" "etcd" {
  name = "etcd"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"
  depends_on = [ "aws_launch_configuration.etcd", "aws_subnet.etcd-a", "aws_subnet.etcd-b", "aws_subnet.etcd-c" ]
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.etcd.name}"
  vpc_zone_identifier = ["${aws_subnet.etcd-a.id}","${aws_subnet.etcd-b.id}","${aws_subnet.etcd-c.id}"]
  
  tag {
    key = "Name"
    value = "etcd"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "etcd" {
  name = "etcd"
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.etcd.name}"
  security_groups = [ "${aws_security_group.etcd.id}" ]
  key_name = "${var.keypair}"  
  lifecycle { create_before_destroy = true }
  depends_on = [ "aws_iam_instance_profile.etcd", "aws_security_group.etcd" ]

  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}" 
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}" 
  }
  
  user_data = "${file("${var.build_dir}/cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

# setup the etcd ec2 profile, role and polices
resource "aws_iam_instance_profile" "etcd" {
    name = "etcd"
    roles = ["${aws_iam_role.etcd.name}"]
    depends_on = [ "aws_iam_role.etcd" ]
}

resource "aws_iam_role_policy" "etcd_policy" {
    name = "etcd_policy"
    role = "${aws_iam_role.etcd.id}"
    policy = "${file(\"${var.build_dir}/policies/etcd_policy.json\")}"
    depends_on = [ "aws_iam_role.etcd" ]
}

resource "aws_iam_role" "etcd" {
    name = "etcd"
    path = "/"
    assume_role_policy =  "${file(\"${var.build_dir}/policies/assume_role_policy.json\")}"
}



