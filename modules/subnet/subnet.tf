# subnet

variable "subnet_name" { }
variable "vpc_id" { }
variable "subnet_cidr" { }
variable "subnet_az" { }
variable "route_table_id" { }

resource "aws_subnet" "subnet" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "${var.subnet_az}"
    cidr_block = "${var.subnet_cidr}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "${var.subnet_name}"
    }
}

resource "aws_route_table_association" "rt" {
    subnet_id = "${aws_subnet.subnet.id}"
    route_table_id = "${var.route_table_id}"
}

output "id" { value = "${aws_subnet.subnet.id}" }
output "az" { value = "${var.subnet_az}" }