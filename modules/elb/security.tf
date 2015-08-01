resource "aws_security_group" "elb"  {
    name = "elb"
    vpc_id = "${var.vpc_id}"
    description = "elb"

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
      Name = "elb"
    }

    tags {
      Name = "elb"
    }
}

output "security_group_elb" {
    value = "${aws_security_group.elb.id}"
}
