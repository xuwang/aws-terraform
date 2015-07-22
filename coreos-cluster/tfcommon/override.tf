
variable "environment" {
  default = "green"
}
variable "aws_instance_type" {
  default = "t2.micro"
}

variable "project_tags" {
  default = {
    coreos_cluster = "coreos-cluster"
    public_domain = "dockerage.com"
    private_domain = "coreos-cluster.local"
  }
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
