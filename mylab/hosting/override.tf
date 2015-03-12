variable "image_id" {
  default = {
    us-west-2 = "ami-a387a093"
  }
}
#variable "environment" {
#  default = "test"
#}
variable "aws_instance_type" {
  default = "t2.medium"
}

