resource "aws_db_subnet_group" "cluster_db" {
    name = "${var.cluster_name}-db"
    description = "db subnets for ${var.cluster_name} applications"
    subnet_ids = ["${var.rds_subnet_a_id}","${var.rds_subnet_b_id}","${var.rds_subnet_c_id}"]
}

resource "aws_security_group" "rds"  {
    name = "rds"
    vpc_id = "${var.cluster_vpc_id}"
    description = "rds SG"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow MySQL access
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["${var.cluster_vpc_cidr}", "${var.allow_ssh_cidr}"]
    }
    # Allow PostgresSQL access
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp" 
      cidr_blocks = ["${var.cluster_vpc_cidr}", "${var.allow_ssh_cidr}"]
    }
}
