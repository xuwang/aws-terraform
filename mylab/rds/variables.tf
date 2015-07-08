variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_account_id" {
  default = "012345678901"
}

variable "environment" {
  default = "green"
}
variable "aws_instance_type" {
  default = "m3.medium"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "aws_availability_zone" {
  default = "us-west-2a"
}

# The net block (CIDR) that SSH is available to.
variable "allow_from_anywhere" {
  default = "0.0.0.0/0"
}

variable "allow_from_supub" {
  default = "171.64.0.0/14"
}
variable "allow_from_su_pub_vpn" {
  default = "171.66.0.0/16"
}
variable "allow_from_mylab_forsythe" {
  default = "171.66.7.0/24"
}

# get updates at https://s3.amazonaws.com/coreos.com/dist/aws/coreos-beta-hvm.template
variable "amis" {
  default = {
    us-east-1 = "ami-fe60d496"
    us-west-2 = "ami-0789a437"
  }
}

variable "iam_instance_profile" {
    default = {
      admiral = "admiral"
      etcd = "etcd"
      hosting = "hosting"
      dockerhub = "dockerhub"
      its-dashboard = "its-dashboard"
    }
}

variable "aws_ec2_keypair" {
    default = {
      admiral = "admiral"
      etcd = "etcd"
      hosting = "hosting"
      dockerhub = "dockerhub"
      its-dashboard = "its-dashboard"
    }
}

variable "project_tag_mylab" {
  default = {
    key = "mylab:billing"
    value = "mylabplatform"
  }
}

variable "project_tag_its-dashboard" {
    default = {
      key = "Billing"
      value = "itsappsup"
    }
}

# primary hosted zone id
variable "aws_route53_zone_id_primary" {
  default = "Z11XFUMVHH2M4Z"
}

# primary hosted zone id
variable "aws_route53_zone_id_postgresdb" {
  default = "ZMT1CXRYMBKG9"
}
