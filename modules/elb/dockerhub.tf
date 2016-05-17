#
# ELB for dockerhub
#

variable "dockerhub_cert" { default = "certs/site.pem" }
variable "dockerhub_cert_chain" { default = "certs/rootCA.pem" }
variable "dockerhub_cert_key" { default = "certs/site-key.pem" }

resource "aws_elb" "dockerhub" {
  name = "dockerhub-elb"
  depends_on = "aws_iam_server_certificate.wildcard"

  security_groups = [ "${aws_security_group.elb.id}" ]
  # This placeholder will be replaced by array of variables defined for VPC zone IDs in the module's variables
  subnets = [ "${var.elb_subnet_a_id}", "${var.elb_subnet_b_id}" ]

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

# Upload a example/demo wildcard cert
resource "aws_iam_server_certificate" "wildcard" {
  name = "wildcard"
  certificate_body = "${file("${var.dockerhub_cert}")}"
  certificate_chain = "${file("${var.dockerhub_cert_chain}")}"
  private_key = "${file("${var.dockerhub_cert_key}")}"

  provisioner "local-exec" {
    command = <<EOF
echo # Sleep 10 secends so that aws_iam_server_certificate.wildcard is truely setup by aws iam service
echo # See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)
sleep 10
EOF
  }
}

/*
# DNS registration
resource "aws_route53_record" "private-dockerhub" {
  zone_id = "${var.route53_private_zone_id}"
  name = "dockerhub"
  type = "A"

  alias {
    name = "${aws_elb.dockerhub.dns_name}"
    zone_id = "${aws_elb.dockerhub.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "public-dockerhub" {
  zone_id = "${var.route53_public_zone_id}"
  name = "dockerhub"
  type = "A"

  alias {
    name = "${aws_elb.dockerhub.dns_name}"
    zone_id = "${aws_elb.dockerhub.zone_id}"
    evaluate_target_health = true
  }
}
*/

output "dockerhub_elb_id" {
    value = "${aws_elb.dockerhub.id}"
}
