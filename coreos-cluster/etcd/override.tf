
variable "amis" {
  default = {
    us-west-2 = "ami-071d1937"
  }
}
variable "environment" {
  default = "mylab"
}
variable "aws_instance_type" {
  default = "t2.medium"
}
