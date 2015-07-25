#
# Jenkins CI ELB configurations
#

#
# Docker jenkins ELB configurations
#
resource "aws_elb" "ci" {
  name = "ci-elb"
  depends_on = "aws_iam_server_certificate.wildcard"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8080
    instance_protocol = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.wildcard.arn}"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8080
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

}

resource "aws_route53_record" "ci" {
  zone_id = "${var.aws_route53_primary_zone_id}"
  name = "ci"
  type = "A"
  
  alias {
    name = "${aws_elb.ci.dns_name}"
    zone_id = "${aws_elb.ci.zone_id}"
    evaluate_target_health = true
  }
}
