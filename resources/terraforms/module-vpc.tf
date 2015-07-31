module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
/*
# can be configured:
    variable "etcd_subnet_a" { default = "10.0.1.0/26" }
    variable "etcd_subnet_b" { default = "10.0.1.64/26" }
    variable "etcd_subnet_c" { default = "10.0.1.128/26" }
    variable "etcd_subnet_az_a" { default = "us-west-2a" }
    variable "etcd_subnet_az_b" { default = "us-west-2b" }
    variable "etcd_subnet_az_c" { default = "us-west-2c" }
    
    variable "worker_subnet_a" { default = "10.0.200.0/24" }
    variable "worker_subnet_b" { default = "10.0.201.0/24" }
    variable "worker_subnet_c" { default = "10.0.202.0/24" }
    variable "worker_subnet_az_a" { default = "us-west-2a" }
    variable "worker_subnet_az_b" { default = "us-west-2b" }
    variable "worker_subnet_az_c" { default = "us-west-2c" }

    variable "admiral_subnet_a" { default = "10.0.100.0/24" }
    variable "admiral_subnet_b" { default = "10.0.101.0/24" }
    variable "admiral_subnet_c" { default = "10.0.102.0/24" }
    variable "admiral_subnet_az_a" { default = "us-west-2a" }
    variable "admiral_subnet_az_b" { default = "us-west-2b" }
    variable "admiral_subnet_az_c" { default = "us-west-2c" }
 */
}