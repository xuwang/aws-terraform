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

# get updates at https://s3.amazonaws.com/coreos.com/dist/aws/coreos-beta-hvm.template
variable "amis" {
  default = {
    us-east-1 = "ami-fe60d496"
    us-west-2 = "ami-abc2889b"
  }
}

variable "iam_instance_profile" {
    default = {
      core = "core"
      etcd = "core"
      hosting = "hosting"
    }
}

variable "aws_ec2_keypair" {
    default = {
      core = "core"
      etcd = "etcd"
      hosting = "hosting"
    }
}

variable "project_tags" {
  default = {
    mylab = "Key=Billing,Value=mylabplatform"
  }
}

