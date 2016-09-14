
# cluster variables
variable "cluster_name" { }
variable "asg_name" { }
# a list of subnet IDs to launch resources in.
variable "cluster_vpc_zone_identifiers" { }
variable "cluster_security_groups" { }
variable "cluster_min_size" { }
variable "cluster_max_size" { }
variable "cluster_desired_capacity" { }
variable "load_balancers" { }

# Instance specifications
variable "ami" { }
variable "image_type" { default = "t2.micro" }
variable "keypair" { }
variable "root_volume_type" { default = "gp2" }
variable "root_volume_size" { default = 12 }
variable "docker_volume_type"  { default = "gp2" }
variable "docker_volume_size" { default = 12 }
variable "data_volume_type"  { default = "gp2" }
variable "data_volume_size" { default = 12 }
variable "user_data" { }
variable "iam_role_policy" { }
