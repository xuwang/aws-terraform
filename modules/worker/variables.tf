variable "vpc_id" { }
variable "vpc_route_table" { }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "allow_ssh_cidr" { default = "0.0.0.0/0" }
variable "aws_region" { default = "us-west-2" }
variable "aws_account_id" { }
variable "ami" { }
variable "image_type" { default = "t2.micro" }
variable "cluster_min_size" { default = 1 }
variable "cluster_max_size" { default = 9 }
variable "cluster_desired_capacity" { default = 3 }
variable "keypair" { default = "etcd" }
variable "root_volume_size" { default = 12 }
variable "ebs_volume_size" { default = 80 }

variable "worker_net" {
    default = {
        us-west-2a = "10.0.5.0/26"
        us-west-2b = "10.0.5.64/26"
        us-west-2c = "10.0.5.128/26"
    }
}
