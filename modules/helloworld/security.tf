resource "aws_security_group" "helloworld"  {
    name = "helloworld"
    vpc_id = "${var.vpc_id}"
    description = "helloworld"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }


    # Allow SSH from my hosts
    ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "helloworld"
    }
}
