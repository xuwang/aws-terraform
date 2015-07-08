#
# Docker registry public facing ELB configurations
#

resource "aws_elb" "dockerhub_elb" {
  name = "dockerhub-${var.environment}-elb"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 5080
    instance_protocol = "http"
    ssl_certificate_id = "${var.elb_wildcard_cert}"
  }

  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:5080/_ping"
    interval = 30
  }

  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ./update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.dockerhub_elb.name} dockerhub.mylab.example.com
CMD_DATA
    }
}

