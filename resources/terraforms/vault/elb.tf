#
# ELB for Vault

# Upload a example/demo wildcard cert
resource "aws_iam_server_certificate" "wildcard" {
  name_prefix = "vault-"
  certificate_body = "${file("${var.vault_cert}")}"
  certificate_chain = "${file("${var.vault_cert_chain}")}"
  private_key = "${file("${var.vault_cert_key}")}"

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

resource "aws_security_group" "elb_vault"  {
    name = "${var.cluster_name}-elb-vault"
    vpc_id = "${var.cluster_vpc_id}"
    description = "${var.cluster_name} elb-vault"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
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
      Name = "${var.cluster_name}-elb-vault"
    }
}

resource "aws_elb" "vault" {
    name = "vault"
    connection_draining = true
    connection_draining_timeout = 400
    internal = true
    subnets = ["${var.elb_subnet_0_id}","${var.elb_subnet_1_id}","${var.elb_subnet_2_id}"]
    security_groups = ["${aws_security_group.elb.id}"]

    listener {
        instance_port = 8200
        instance_protocol = "tcp"
        lb_port = 80
        lb_protocol = "tcp"
    }

    listener {
        instance_port = 8200
        instance_protocol = "tcp"
        lb_port = 443
        lb_protocol = "tcp"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 3
        timeout = 5
        target = "${var.elb-health-check}"
        interval = 15
    }

    tags {
      Name = "${var.cluster_name}-elb-vault"
    }
}

resource "aws_security_group" "elb" {
    name = "vault-elb"
    description = "Vault ELB"
    vpc_id = "${var.cluster_vpc_id}"
}

resource "aws_security_group_rule" "vault-elb-http" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault-elb-https" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault-elb-egress" {
    security_group_id = "${aws_security_group.elb.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

/*
# DNS registration
resource "aws_route53_record" "private-vault" {
  zone_id = "${var.route53_private_zone_id}"
  name = "vault"
  type = "A"
  
  alias {
    name = "${aws_elb.vault.dns_name}"
    zone_id = "${aws_elb.vault.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "public-vault" {
  zone_id = "${var.route53_public_zone_id}"
  name = "vault"
  type = "A"
  
  alias {
    name = "${aws_elb.vault.dns_name}"
    zone_id = "${aws_elb.vault.zone_id}"
    evaluate_target_health = true
  }
}
*/
output "security_group_elb_vault" {
    value = "${aws_security_group.elb_vault.id}"
}
output "elb_name" {
    value = "${aws_elb.vault.id}"
}
