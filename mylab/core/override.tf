variable "image_id" {
  default = {
    us-west-2 = "ami-f1702bc1"
  }
}
#variable "environment" {
#  default = "test"
#}
variable "aws_instance_type" {
  default = "t2.medium"
}

