#
# Gmylab CI ELB configurations
#

resource "aws_elb" "gmylab_elb" {
  name = "gmylab-${var.environment}-elb"
  
  security_groups = [ "${var.security_group_elb}" ]
  subnets = ["${var.subnet_elb-us-west-2a}","${var.subnet_elb-us-west-2b}","${var.subnet_elb-us-west-2c}"]
  cross_zone_load_balancing = "true"
  
  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 10080
    instance_protocol = "http"
    ssl_certificate_id = "${var.elb_wildcard_cert}"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:10080"
    interval = 30
  }

  # SSH for gmylab
  listener {
    lb_port = 10022
    lb_protocol = "tcp"
    instance_port = 10022
    instance_protocol = "tcp"
  }

  # Workaround for Alias type
  provisioner "local-exec" {
      command = <<CMD_DATA
         ./update-route53.sh ${var.aws_route53_zone_id_primary} ${aws_elb.gmylab_elb.name} git-new.mylab.example.com
CMD_DATA
    }
}
