
variable "environment" {
  default = "green"
}
variable "aws_instance_type" {
  default = {
    etcd = "t2.micro"
    worker = "t2.micro"
    dockerhub = "t2.micro"
    admiral = "t2.micro"
  }
}
variable "project_tags" {
  default = {
    coreos_cluster = "coreos-cluster"
    public_domain = "dockerage.com"
    private_domain = "coreos-cluster.local"
  }
}
# etcd_cluster_capacity should be in odd number, e.g. 3, 5, 9
variable "etcd_cluster_capacity" {
  default = {
    min_size = 1
    max_size = 1
    desired_capacity = 1
  }
}

variable "worker_cluster_capacity" {
  default = {
    min_size = 1
    max_size = 1
    desired_capacity = 1
  }
}

variable "dockerhub_cluster_capacity" {
  default = {
    min_size = 1
    max_size = 1
    desired_capacity = 1
  }
}

variable "admiral_cluster_capacity" {
  default = {
    min_size = 1
    max_size = 1
    desired_capacity = 1
  }
}