variable "instance_class" { default = "db.t1.micro" }
variable "db_user" { default = "root" }
variable "db_password" { }

# networking vars set by module.vpc
variable "vpc_id" { }
variable "vpc_cidr" { }

# This placeholder will be replaced by module subnet id and availability zone tf variable definations
# For more information look into 'substitute-VPC-AZ-placeholders.sh'
<%MODULE-SUBNET-VARIABLES%>
