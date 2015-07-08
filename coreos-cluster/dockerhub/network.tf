# Docker Vpc
variable "vpc_id" {}
variable "vpc_cidr" {}

# Hosting network
variable "subnet_hosting-us-west-2a" {}
variable "subnet_hosting-us-west-2b" {}
variable "subnet_hosting-us-west-2c" {}

# RDS network
variable "subnet_rds-us-west-2a" {}
variable "subnet_rds-us-west-2b" {}
variable "subnet_rds-us-west-2c" {}

# Controller network
variable "subnet_admiral-us-west-2a"  {}
variable "subnet_admiral-us-west-2b" {}
variable "subnet_admiral-us-west-2c" {}

# Controller network
variable "subnet_admiral-us-west-2a"  {}
variable "subnet_admiral-us-west-2b" {}

# Controller network - same as admiral
variable "subnet_etcd-a-us-west-2a"  {}
variable "subnet_etcd-b-us-west-2b" {}
variable "subnet_etcd-c-us-west-2c" {}

# External loadbalacner network
variable "subnet_ext_elb-us-west-2a"  {}
variable "subnet_ext_elb-us-west-2b"  {}
variable "subnet_ext_elb-us-west-2c"  {}

# Bastionnetwork
variable "subnet_bastion-us-west-2a"  {}
variable "subnet_bastion-us-west-2b" {}
variable "subnet_bastion-us-west-2c" {}

# Security groups
variable "security_group_admiral" {}
variable "security_group_bastion" {}
variable "security_group_dockerhub" {}
variable "security_group_etcd" {}
variable "security_group_hosting" {}
variable "security_group_rds" {}
variable "security_group_docker-ext-elb" {}

variable "etcd_private_ip" {
    default = {
      us-west-2a = "10.0.2.50"
      us-west-2b = "10.0.2.100"
      us-west-2c = "10.0.2.150"
    }
}

variable "etcd2_private_ip" {
    default = {
      us-west-2a = "10.0.2.51"
      us-west-2b = "10.0.2.101"
      us-west-2c = "10.0.2.151"
    }
}

variable "project_tag" {
  default = {
    sws = "Key=mylab:billing,Value=swsplatform"
  }
}

# Mylab hosted zone id
variable "aws_route53_zone_id_mylab" {
  default = "Z11XFUMVHH2M4Z"
}

# load balancer hosted zone id in us-west
variable "aws_elb_hosted_zone_id" {
  default = "Z33MTJ483KN6FU"
}

# load balancer hosted zone id in us-west
variable "aws_route53_zone_id_db" {
  default = ""
}
