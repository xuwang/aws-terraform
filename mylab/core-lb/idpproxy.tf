#
# Docker idpproxy ELB

resource "aws_elb" "idpproxy_elb" {
  name = "idpproxy-${var.environment}-elb"
  
  security_groups = [ "${var.security_group_docker-ext-elb}" ]
  subnets = ["${var.subnet_ext_elb-us-west-2a}","${var.subnet_ext_elb-us-west-2b}","${var.subnet_ext_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8018
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::012345678901:server-certificate/MyLabWildCardCert201711"
  }
  
  listener {
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8018
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8018"
    interval = 30
  }
  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ./update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.idpproxy_elb.name} idpproxy.mylab.example.com
CMD_DATA
    }
}

/*
resource "aws_route53_record" "idpproxy" {
    zone_id = "${var.aws_route53_zone_id_primary}"
    name = "nodeapp.mylab.example.com"
    type = "A"
    ttl = "60"
    records = [ "{aws_elb.idpproxy_elb.name}" ]
    depends_on = ["aws_elb.idpproxy_dev_elb"]
    
    # Workaround for Alias type
     provisioner "local-exec" {
         command = <<CMD_DATA
         ../ops/scripts/update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.idpproxy_elb.name} ${aws_route53_record.nodeapp.name}
CMD_DATA
    }
}
*/
