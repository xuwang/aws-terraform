#
# Docker hosting autoscale group configurations
#
resource "aws_autoscaling_group" "docker_hosting" {
  name = "docker-hosting"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c"]
  max_size = 9
  min_size = 2
  desired_capacity = 2
  
  health_check_type = "EC2"
  force_delete = true
  
  # If first time build, use this:
  launch_configuration = "${aws_launch_configuration.docker_hosting.name}"
  #launch_configuration = "docker-hosting-v2"
  vpc_zone_identifier = ["${var.subnet_hosting-us-west-2a}","${var.subnet_hosting-us-west-2b}","${var.subnet_hosting-us-west-2c}"]
  #load_balancers = [ "${aws_elb.docker_hosting.name}" ]  
  #depends_on = ["aws_launch_configuration.docker_hosting"]
  
  # Workround to implement tagging for the time being: Tag: Key = mylab:billing Value = swsplatform
  provisioner "local-exec" {
      command = <<CMD_DATA
aws --profile mylab autoscaling create-or-update-tags --tags \
ResourceId=${aws_autoscaling_group.docker_hosting.id},\
ResourceType=auto-scaling-group,Key=Name,Value=docker-hosting,PropagateAtLaunch=true \
ResourceId=${aws_autoscaling_group.docker_hosting.id},\
ResourceType=auto-scaling-group,${var.project_tags.mylab},PropagateAtLaunch=true\
CMD_DATA
  }
}

output "aws-autoscaling-group-id" {
  value = "${aws_autoscaling_group.docker_hosting.id}"
}

# Until terraform supports device mapping, launch configration need to be updated on AWS console to add extra ebs disk.
resource "aws_launch_configuration" "docker_hosting" {
  name = "docker-hosting"
  image_id = "${lookup(var.image_id, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  #iam_instance_profile = "${var.iam_instance_profile.hosting}"
  security_groups = [ "${var.security_group_hosting}" ]
  key_name = "${var.aws_ec2_keypair.hosting}"  
  #depends_on = ["aws_security_group.docker_hosting"]
  
  user_data = <<USER_DATA
${file("cloud-config/hosting.yaml")}
${file("../common/cloud-config/systemd-units.yaml")}
${file("../common/cloud-config/files.yaml")}
USER_DATA
}

/*
#
# Docker hosting ELB configurations - sites will register their own elb.
#

resource "aws_elb" "docker_hosting" {
  name = "docker-hosting-${var.environment}-elb"
  #depends_on = ["aws_security_group.docker_hosting_elb"]
  
  #availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  subnets = ["${var.subnet.us-west-2a}"]
  
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:22"
    interval = 30
  }
  security_groups = [ "${var.security_group.hosting_elb}" ]
}

output "aws-launch-configuration-id" {
    value = "${aws_launch_configuration.docker_hosting.id}"
}
output "aws-elb-id" {
    value = "${aws_elb.docker_hosting.id}"
}

*/

#
# Docker hosting DNS registrition
#
#resource "aws_route53_record" "docker_hosting" {
#  zone_id = "${var.aws_route53_zone_id_mylab}"
#  name = "docker-hosting.mylab.example.com"
#  type = "CNAME"
#  ttl = "60"
#  records = [ "${aws_elb.docker_hosting.dns_name}" ]
#  
#  depends_on = ["aws_elb.docker_hosting"]
#}

#resource "aws_s3_bucket" "mylab-coreos" {
 # bucket = "mylab-coreos-${var.environment}"
#  acl = "private"
  #provisioner "local-exec" {
   # command = "aws s3 cp ../grafana/dist/grafana-1.8.0 s3://grafana-${var.environment}-nlab-cloud --recursive --acl public-read"
   # command = "aws s3 cp ../grafana/conf/config.js s3://grafana-${var.environment}-nlab-cloud --acl public-read"
   # command = "aws s3 website s3://grafana-${var.environment}-nlab-cloud --index-document index.html"
  #}
  #}

# Something like this should work once Route53 Alias records are supported by Terraform.
#   In the meantime, CNAMEs don't work either, because S3 looks at the HTTP Host header.
# resource "aws_route53_record" "grafana" {
#   zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
#   name = "grafana.${var.environment}.cloud.nlab.io"
#   type = "A"
#   ttl = "60"
#   records = [ "ALIAS grafana-${var.environment}-nlab-cloud.s3-us-west-2.amazonaws.com" ]
# }
