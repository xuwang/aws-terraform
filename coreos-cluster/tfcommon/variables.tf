variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "environment" {
  default = "green"
}

variable "aws_instance_type" {
  default = {
    etcd = "t2.micro"
    worker = "t2.medium"
    dockerhub = "t2.medium"
    admiral = "t2.medium"
  }
}

variable "aws_region" {
  default = "us-west-2"
}

variable "aws_availability_zone" {
  default = "us-west-2a"
}

variable "etcd_cluster_capacity" {
  default = {
    min_size = 3
    max_size = 3
    desired_capacity = 3
  }
}

variable "worker_cluster_capacity" {
  default = {
    min_size = 3
    max_size = 3
    desired_capacity = 3
  }
}

variable "dockerhub_cluster_capacity" {
  default = {
    min_size = 2
    max_size = 2
    desired_capacity = 2
  }
}

variable "admiral_cluster_capacity" {
  default = {
    min_size = 2
    max_size = 2
    desired_capacity = 2
  }
}

# The net block (CIDR) that SSH is available to.
variable "allow_from_anywhere" {
  default = "0.0.0.0/0"
}

# My IP address allowed to access coreos-cluster nodes, NOTE: use your own ip block.
variable "allow_from_myip" {
  default = "0.0.0.0/0"
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
      worker = "worker"
      dockerhub = "dockerhub"
    }
}

variable "aws_ec2_keypair" {
    default = {
      admiral = "admiral"
      etcd = "etcd"
      worker = "worker"
      dockerhub = "dockerhub"
    }
}

variable "project_tags" {
  default = {
    coreos_cluster = "coreos-cluster"
    public_domain = "dockerage.com"
    private_domain = "coreos-cluster.local"
  }
}

# primary hosted zone id
variable "aws_route53_primary_zone_id" {
  default = "to_be_set_by_route53_tf"
}

# private hosted zone id
variable "aws_route53_private_zone_id" {
  default = "to_be_set_by_route53_tf"
}
