variable "instance_class" { default = "db.t1.micro" }
variable "db_user" { default = "root" }
variable "db_password" { }

# networking vars set by module.vpc
variable "vpc_id" { }
variable "vpc_cidr" { }
variable "rds_subnet_a_id" { }
variable "rds_subnet_b_id" { }
variable "rds_subnet_c_id" { }
variable "rds_subnet_az_a" { }
variable "rds_subnet_az_b" { }
variable "rds_subnet_az_c" { }