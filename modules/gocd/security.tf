resource "aws_security_group" "gocd"  {
    name = "gocd"
    vpc_id = "${var.vpc_id}"
    description = "gocd"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # TODO: fix this port?
    # Open gocd port
    ingress {
      from_port = 8153
      to_port = 8153
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc_cidr}" ]
    }

    # Allow SSH from my hosts
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.allow_ssh_cidr}"]
      self = true
    }

    tags {
      Name = "gocd"
    }
}
