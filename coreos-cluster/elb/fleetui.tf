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

resource "aws_elb" "fleetui_elb" {
  name = "fleetui-elb"
  
  security_groups = [ "${aws_security_group.fleetui_elb_sg.id}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "tcp"
    instance_port = 8083
    instance_protocol = "tcp"
    #ssl_certificate_id = "${var.elb_wildcard_cert}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8083"
    interval = 30
  }

  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ../../scripts/update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.fleetui_elb.name} fleetui.mylab.example.com mylab
CMD_DATA
    }
}
