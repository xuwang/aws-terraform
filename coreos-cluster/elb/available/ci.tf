#
# Jenkins CI ELB configurations
#

#
# Docker jenkins ELB configurations
#
resource "aws_elb" "jenkins_elb" {
  name = "jenkins-${var.environment}-elb"
  
  security_groups = [ "${aws_security_group.jenkins_elb.id}" ]
  subnets = ["${var.subnet.us-west-2a}","${var.subnet.us-west-2b}","${var.subnet.us-west-2c}"]
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8080
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::012345678901:server-certificate/ci.example.com"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }
}

# securrity group for docker jenkins ELB
resource "aws_security_group" "jenkins_elb" {
  name = "jenkins-${var.environment}-elb"
  description = "Allow ingress from public."
  vpc_id = "${var.vpc.id}"

  ingress {
    from_port = 443
    to_port =  443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

output "sg-jenkins-elb-id" {
    value = "${aws_security_group.jenkins_elb.id}"
}
output "aws-jenkins-elb-name" {
    value = "${aws_elb.jenkins_elb.name}"
}

#
# Docker jenkins DNS registrition
#
#resource "aws_route53_record" "jenkins" {
#  zone_id = "${var.aws_route53_zone_id_mylab}"
#  name = "jenkins.mylab.example.com"
#  type = "CNAME"
#  ttl = "60"
#  records = [ "${aws_elb.jenkins.dns_name}" ]
#  
#  depends_on = ["aws_elb.jenkins"]
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
