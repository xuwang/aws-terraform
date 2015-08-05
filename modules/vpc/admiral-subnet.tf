# subnet for admiral cluster

variable "admiral_subnet_a" { default = "10.0.10.0/24" }
variable "admiral_subnet_b" { default = "10.0.11.0/24" }
variable "admiral_subnet_c" { default = "10.0.12.0/24" }
variable "admiral_subnet_az_a" { default = "us-west-2a" }
variable "admiral_subnet_az_b" { default = "us-west-2b" }
variable "admiral_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "admiral_a" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.admiral_subnet_az_a}"
    cidr_block = "${var.admiral_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "admiral_a"
    }
}

resource "aws_route_table_association" "admiral_rt_a" {
    subnet_id = "${aws_subnet.admiral_a.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "admiral_b" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.admiral_subnet_az_b}"
    cidr_block = "${var.admiral_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "admiral_b"
    }
}

resource "aws_route_table_association" "admiral_rt_b" {
    subnet_id = "${aws_subnet.admiral_b.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "admiral_c" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.admiral_subnet_az_c}"
    cidr_block = "${var.admiral_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "admiral_c"
    }
}

resource "aws_route_table_association" "admiral_rt_c" {
    subnet_id = "${aws_subnet.admiral_c.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "admiral_subnet_a_id" { value = "${aws_subnet.admiral_a.id}" }
output "admiral_subnet_b_id" { value = "${aws_subnet.admiral_b.id}" }
output "admiral_subnet_c_id" { value = "${aws_subnet.admiral_c.id}" }
output "admiral_subnet_az_a" { value = "${var.admiral_subnet_az_a}" }
output "admiral_subnet_az_b" { value = "${var.admiral_subnet_az_b}" }
output "admiral_subnet_az_c" { value = "${var.admiral_subnet_az_c}" }