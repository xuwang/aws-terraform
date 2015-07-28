#
# FleetUI ELB
#

resource "aws_security_group" "fleetui_elb_sg"  {
    name = "fleetui_elb-sg"
    vpc_id = "${var.vpc_id}" 
    description = "fleetui_elb-sg SG"

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
      Name = "fleetui_elb_sg"
    }
}

resource "aws_elb" "fleetui" {
  name = "fleetui-elb"
  depends_on = "aws_iam_server_certificate.wildcard"
  
  security_groups = [ "${aws_security_group.fleetui_elb_sg.id}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "tcp"
    instance_port = 8083
    instance_protocol = "tcp"
    #ssl_certificate_id = "${aws_iam_server_certificate.wildcard.arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8083"
    interval = 30
  }
}

resource "aws_route53_record" "fleetui" {
  zone_id = "${var.aws_route53_primary_zone_id}"
  name = "fleetui"
  type = "A"
  
  alias {
    name = "${aws_elb.fleetui.dns_name}"
    zone_id = "${aws_elb.fleetui.zone_id}"
    evaluate_target_health = true
  }
}
