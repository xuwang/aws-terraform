# domain for route53 registration
variable "route53_public_zone_id" { }
variable "route53_private_zone_id" { }

# networking vars set by module.vpc
variable "vpc_id" { }
variable "vpc_cidr" { }
variable "elb_subnet_a_id" { }
variable "elb_subnet_b_id" { }
variable "elb_subnet_c_id" { }
variable "elb_subnet_az_a" { }
variable "elb_subnet_az_b" { }
variable "elb_subnet_az_c" { }