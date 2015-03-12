#
# Docker nodeapp  ELB

resource "aws_elb" "nodeapp_elb" {
  name = "nodeapp-${var.environment}-elb"
  
  security_groups = [ "${var.security_group_docker-ext-elb}" ]
  subnets = ["${var.subnet_ext_elb-us-west-2a}","${var.subnet_ext_elb-us-west-2b}","${var.subnet_ext_elb-us-west-2c}"]
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
  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ../ops/scripts/update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.nodeapp_elb.name} nodeapp.mylab.example.com
CMD_DATA
    }
}

/*
resource "aws_route53_record" "nodeapp" {
    zone_id = "${var.aws_route53_zone_id_primary}"
    name = "nodeapp.mylab.example.com"
    type = "A"
    ttl = "60"
    records = [ "{aws_elb.nodeapp_elb.name}" ]
    depends_on = ["aws_elb.nodeapp_elb"]
    
    # Workaround for Alias type
     provisioner "local-exec" {
         command = <<CMD_DATA
         ../ops/scripts/update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.nodeapp_elb.name} ${aws_route53_record.nodeapp.name}
CMD_DATA
    }
}
*/
