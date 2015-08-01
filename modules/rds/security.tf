resource "aws_security_group" "rds"  {
    name = "rds"
    vpc_id = "${var.vpc_id}"
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
      cidr_blocks = ["${var.vpc_cidr}" ]
    }
    # Allow PostgresSQL access
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}" ]
    }
}