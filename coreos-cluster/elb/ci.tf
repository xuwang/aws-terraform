#
# Jenkins CI ELB configurations
#

#
# Docker jenkins ELB configurations
#
resource "aws_elb" "jenkins_elb" {
  name = "jenkins-${var.environment}-elb"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8080
    instance_protocol = "http"
    ssl_certificate_id = "${var.elb_wildcard_cert}"
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

  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ./update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.jenkins_elb.name} ci.mylab.example.com
CMD_DATA
    }
}
