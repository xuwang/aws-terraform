
variable "amis" {
  default = {
    us-west-2 = "ami-071d1937"
  }
}
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
