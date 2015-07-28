#
# Gmylab CI ELB configurations
#

resource "aws_elb" "gitlab" {
  name = "gitlab"
  depends_on = "aws_iam_server_certificate.wildcard"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 10080
    instance_protocol = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.wildcard.arn}"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:10080"
    interval = 30
  }

  # SSH for gitlab
  listener {
    lb_port = 10022
    lb_protocol = "tcp"
    instance_port = 10022
    instance_protocol = "tcp"
  }
}

resource "aws_route53_record" "gitlab" {
  zone_id = "${var.aws_route53_primary_zone_id}"
  name = "gitlab"
  type = "A"
  
  alias {
    name = "${aws_elb.gitlab.dns_name}"
    zone_id = "${aws_elb.gitlab.zone_id}"
    evaluate_target_health = true
  }
}
