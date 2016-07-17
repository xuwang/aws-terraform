variable "vpc_id" { default = "coreos-cluster" }
variable "public_domain" { default="dockerage.com" }
variable "private_domain" { default="coreos-cluster.local" }

resource "aws_route53_zone" "public" {
    name = "${var.public_domain}"

    tags {
        Name = "${var.public_domain}"
    }

}

resource "aws_route53_zone" "private" {
    name = "${var.private_domain}"   
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "${var.private_domain}"
    }
}