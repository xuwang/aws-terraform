#
# Dashboard CI ELB configurations
#

resource "aws_elb" "its-dashboard_elb" {
  name = "its-dashboard-${var.environment}-elb"
  
  security_groups = [ "${var.security_group_docker-ext-elb}" ]
  subnets = ["${var.subnet_ext_elb-us-west-2a}","${var.subnet_ext_elb-us-west-2b}","${var.subnet_ext_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8080
    instance_protocol = "http"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8443
    instance_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::012345678901:server-certificate/MyLabWildCardCert201711"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8443"
    interval = 30
  }

  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ./update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.its-dashboard_elb.name} dashboard.mylab.example.com
CMD_DATA
    }
}
