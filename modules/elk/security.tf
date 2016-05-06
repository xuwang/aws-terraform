resource "aws_security_group" "elk"  {
    name = "elk"
    vpc_id = "${var.vpc_id}"
    description = "elk stack"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # Open kibana port
    ingress {
      from_port = 5601
      to_port = 5601
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc_cidr}" ]
    }

    # Open elastic search port
    ingress {
      from_port = 9200
      to_port = 9200
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc_cidr}" ]
    }    

    # Open logstash port
    ingress {
      from_port = 5044
      to_port = 5044
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
      Name = "elk"
    }
}