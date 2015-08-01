module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
/*
# can be configured:
    variable "etcd_subnet_a" { default = "10.0.1.0/26" }
    variable "etcd_subnet_b" { default = "10.0.1.64/26" }
    variable "etcd_subnet_c" { default = "10.0.1.128/26" }

    variable "admiral_subnet_a" { default = "10.0.10.0/24" }
    variable "admiral_subnet_b" { default = "10.0.11.0/24" }
    variable "admiral_subnet_c" { default = "10.0.12.0/24" }
    
    variable "worker_subnet_a" { default = "10.0.20.0/24" }
    variable "worker_subnet_b" { default = "10.0.21.0/24" }
    variable "worker_subnet_c" { default = "10.0.22.0/24" }

    variable "elb_subnet_a" { default = "10.0.30.0/24" }
    variable "elb_subnet_b" { default = "10.0.31.0/24" }
    variable "elb_subnet_c" { default = "10.0.32.0/24" }

    variable "rds_subnet_a" { default = "10.0.40.0/24" }
    variable "rds_subnet_b" { default = "10.0.41.0/24" }
    variable "rds_subnet_c" { default = "10.0.42.0/24" }
*/
}