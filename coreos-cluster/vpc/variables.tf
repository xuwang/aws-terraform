variable "aws_access_key" {}
variable "aws_secret_key" {}

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

variable "allow_from_myip" {
  default = "108.84.154.184/32"
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
    }
}

variable "aws_ec2_keypair" {
    default = {
      admiral = "admiral"
      etcd = "etcd"
      hosting = "hosting"
      dockerhub = "dockerhub"
    }
}

variable "project_tags" {
  default = {
    sws = "Key=Billing,Value=swsplatform"
    mylab = "Key=Billing,Value=mylabplatform"
  }
}

# primary hosted zone id
variable "aws_route53_zone_id_primary" {
  default = "Z11XFUMVHH2M4Z"
}
