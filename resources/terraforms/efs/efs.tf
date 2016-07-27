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
    name = "${var.cluster_name}-efs"
    vpc_id = "${var.cluster_vpc_id}"
    description = "efs"

    # Allow all outound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # EFS client port
    ingress {
      from_port = 2049
      to_port = 2049
      protocol = "tcp"
      cidr_blocks = ["${var.cluster_vpc_cidr}"]
    }

    tags {
      Name = "${var.cluster_name}-efs"
    }
}

output "efs_file_system_efs_id" { value = "${aws_efs_file_system.efs.id}" }
output "security_group_efs_id" { value = "${aws_security_group.efs.id}" }

module "efs-target" {
    source = "../../modules/efs-target"
    filesystem_id = "${aws_efs_file_system.efs.id}"
    security_group_id = "${aws_security_group.efs.id}"
    efs_subnet_a_id = "${var.worker_subnet_a_id}"
    efs_subnet_b_id = "${var.worker_subnet_b_id}"
    efs_subnet_c_id = "${var.worker_subnet_c_id}"
}
