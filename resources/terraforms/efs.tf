# EFS cluster
resource "aws_efs_file_system" "efs" {
  reference_name = "${var.cluster_name}-efs"
  tags {
    Name = "${var.cluster_name}-efs"
  }
  tags {
    Billing = "${var.cluster_name}"
  }
}

resource "aws_security_group" "efs"  {
    name = "efs"
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    description = "efs"

    # Allow all outound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # EFS
    ingress {
      from_port = 2049
      to_port = 2049
      protocol = "tcp"
      cidr_blocks = ["10.42.0.0/16"]
    }

    tags {
      Name = "efs"
    }
}
