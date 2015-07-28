#
# Docker nodeapp  ELB

resource "aws_elb" "nodeapp" {
  name = "nodeapp-elb"
  depends_on = "aws_iam_server_certificate.wildcard"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8000
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

resource "aws_route53_record" "nodeapp" {
  zone_id = "${var.aws_route53_primary_zone_id}"
  name = "nodeapp"
  type = "A"
  
  alias {
    name = "${aws_elb.nodeapp.dns_name}"
    zone_id = "${aws_elb.nodeapp.zone_id}"
    evaluate_target_health = true
  }
}