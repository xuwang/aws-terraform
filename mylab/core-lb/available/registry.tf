#
# Docker registry public facing ELB configurations
#

# securrity group for public docker registry ELB
resource "aws_security_group" "dk_registry_ext" {
  name = "docker-registry-ext-${var.environment}-elb"
  description = "Allow ingress from public."
  vpc_id = "${var.vpc.id}"
  
  ingress {
    from_port = 443
    to_port =  443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# securrity group for private docker registry ELB
resource "aws_security_group" "dk_registry_int" {
  name = "docker-registry-int-${var.environment}-elb"
  description = "Allow ingress from private net."
  vpc_id = "${var.vpc.id}"

  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "${var.vpc.cidr}" ]
  }
}

output "sg-docker-registry-ext-elb-id" {
    value = "${aws_security_group.dk_registry_ext.id}"
}
output "sg-docker-registry-int-elb-id" {
    value = "${aws_security_group.dk_registry_int.id}"
}

resource "aws_elb" "dk_registry_ext" {
  name = "docker-registry-ext-${var.environment}-elb"
  
  security_groups = [ "${aws_security_group.dk_registry_ext.id}" ]
  subnets = ["${var.subnet.us-west-2a}","${var.subnet.us-west-2b}","${var.subnet.us-west-2c}"]
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 5080
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::012345678901:server-certificate/docker-registry.example.com"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:5080/_ping"
    interval = 30
  }

#
# Docker registry internal facing ELB configurations
#
resource "aws_elb" "dk_registry_int" {
  name = "docker-registry-int-${var.environment}-elb"
  internal = true
  
  security_groups = [ "${aws_security_group.dk_registry_int.id}" ] 
  subnets = ["${var.subnet.us-west-2a}","${var.subnet.us-west-2b}","${var.subnet.us-west-2c}"]
  
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 5000
    instance_protocol = "http"
  }
  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "HTTP:5000/_ping"
    interval = 30
  }
}
# TODO: enable cross zone through postprovisioning
#aws elb modify-load-balancer-attributes --load-balancer-name my-test-loadbalancer --load-balancer-attributes #"{\"CrossZoneLoadBalancing\":{\"Enabled\":true}}"

output "aws-ext-elb-id" {
    value = "${aws_elb.dk_registry_ext.id}"
}
output "aws-ext-elb-name" {
    value = "${aws_elb.dk_registry_ext.name}"
}
output "aws-int-elb-id" {
    value = "${aws_elb.dk_registry_int.id}"
}
output "aws-int-elb-name" {
    value = "${aws_elb.dk_registry_int.name}"
}
#
# Docker registry DNS registrition
#
#resource "aws_route53_record" "dk_registry" {
#  zone_id = "${var.aws_route53_zone_id_mylab}"
#  name = "docker-registry.mylab.example.com"
#  type = "CNAME"
#  ttl = "60"
#  records = [ "${aws_elb.dk_registry.dns_name}" ]
#  
#  depends_on = ["aws_elb.dk_registry"]
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
