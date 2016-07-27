#
# ELB for CI
#

variable "ci_cert" { default = "../certs/site.pem" }
variable "ci_cert_chain" { default = "../certs/rootCA.pem" }
variable "ci_cert_key" { default = "../certs/site-key.pem" }

resource "aws_elb" "ci" {
  name = "${var.cluster_name}-elb-ci"
  depends_on = [ "aws_iam_server_certificate.wildcard" ]  
  subnets = ["${var.elb_subnet_a_id}","${var.elb_subnet_b_id}","${var.elb_subnet_c_id}"]
  security_groups = [ "${aws_security_group.elb_ci.id}" ]

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8080
    instance_protocol = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.wildcard.arn}"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8080
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  tags {
      Name = "${var.cluster_name}-elb-ci"
  }
}

# Upload a example/demo wildcard cert
resource "aws_iam_server_certificate" "wildcard" {
  name = "${var.app_domain}"
  certificate_body = "${file("${var.ci_cert}")}"
  certificate_chain = "${file("${var.ci_cert_chain}")}"
  private_key = "${file("${var.ci_cert_key}")}"

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = <<EOF
echo # Sleep 10 secends so that aws_iam_server_certificate.wildcard is truely setup by aws iam service
echo # See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)
sleep 10
EOF
  }
}

resource "aws_security_group" "elb_ci"  {
    name = "${var.cluster_name}-elb-ci"
    vpc_id = "${var.cluster_vpc_id}"
    description = "${var.cluster_name} elb-ci"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "${var.cluster_name}-elb-ci"
    }
}

# DNS registration
resource "aws_route53_record" "private-ci" {
  zone_id = "${var.route53_private_zone_id}"
  name = "ci"
  type = "A"
  
  alias {
    name = "${aws_elb.ci.dns_name}"
    zone_id = "${aws_elb.ci.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "public-ci" {
  zone_id = "${var.route53_public_zone_id}"
  name = "ci"
  type = "A"
  
  alias {
    name = "${aws_elb.ci.dns_name}"
    zone_id = "${aws_elb.ci.zone_id}"
    evaluate_target_health = true
  }
}

output "security_group_elb" {
    value = "${aws_security_group.elb_ci.id}"
}
output "elb_name" {
    value = "${aws_elb.ci.id}"
}
