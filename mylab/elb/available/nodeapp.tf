#
# Docker nodeapp  ELB
#

# securrity group for public docker registry ELB
resource "aws_security_group" "nodeapp_elb" {
  name = "docker-nodeapp-${var.environment}-elb"
  description = "Allow ingress from public."
  vpc_id = "${var.vpc.id}"
  
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

output "sg-nodeapp-elb-id" {
    value = "${aws_security_group.nodeapp_elb.id}"
}

resource "aws_elb" "nodeapp_elb" {
  name = "docker-nodeapp-${var.environment}-elb"
  
  security_groups = [ "${aws_security_group.nodeapp_elb.id}" ]
  subnets = ["${var.subnet.us-west-2a}","${var.subnet.us-west-2b}","${var.subnet.us-west-2c}"]
  
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
    target = "TCP:8000"
    interval = 30
  }
}

#
# Docker registry DNS registrition
#
resource "aws_route53_record" "nodeapp" {
    zone_id = "${var.aws_route53_zone_id_mylab}"
    name = "nodeapp.mylab.example.com"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_elb.nodeapp_elb.dns_name}" ]
    depends_on = ["aws_elb.nodeapp_elb"]
    
    # Workround to implement tagging for the time being: Tag: Key = mylab:billing Value = swsplatform
    # Workaround for Alias type
    provisioner "local-exec" {
        command = <<CMD_DATA
  sed -i '' "s/DNSNAME/${aws_route53_record.nodeapp.name}/" update-route53.json
  sed -i '' "s/ELBDNSNAME/${aws_elb.nodeapp_elb.dns_name}/" update-route53.json
  ./update-route53.sh \
CMD_DATA
    }
}

output "nodeapp_elb-id" {
    value = "${aws_elb.nodeapp_elb.id}"
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