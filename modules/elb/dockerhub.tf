#
# Docker registry public facing ELB configurations
#


resource "aws_elb" "dockerhub" {
  name = "dockerhub-elb"
  depends_on = "aws_iam_server_certificate.wildcard"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 5080
    instance_protocol = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.wildcard.arn}"
  }

  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:5080/_ping"
    interval = 30
  }
}

resource "aws_route53_record" "dockerhub" {
  zone_id = "${var.aws_route53_primary_zone_id}"
  name = "dockerhub"
  type = "A"
  
  alias {
    name = "${aws_elb.dockerhub.dns_name}"
    zone_id = "${aws_elb.dockerhub.zone_id}"
    evaluate_target_health = true
  }
}

