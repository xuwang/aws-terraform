# subnet for elb cluster

variable "elb_subnet_a" { default = "10.0.30.0/24" }
variable "elb_subnet_b" { default = "10.0.31.0/24" }
variable "elb_subnet_c" { default = "10.0.32.0/24" }
variable "elb_subnet_az_a" { default = "us-west-2a" }
variable "elb_subnet_az_b" { default = "us-west-2b" }
variable "elb_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "elb_a" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.elb_subnet_az_a}"
    cidr_block = "${var.elb_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "elb_a"
    }
}

resource "aws_route_table_association" "elb_rt_a" {
    subnet_id = "${aws_subnet.elb_a.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "elb_b" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.elb_subnet_az_b}"
    cidr_block = "${var.elb_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "elb_b"
    }
}

resource "aws_route_table_association" "elb_rt_b" {
    subnet_id = "${aws_subnet.elb_b.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "elb_c" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.elb_subnet_az_c}"
    cidr_block = "${var.elb_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "elb_c"
    }
}

resource "aws_route_table_association" "elb_rt_c" {
    subnet_id = "${aws_subnet.elb_c.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "elb_subnet_a_id" { value = "${aws_subnet.elb_a.id}" }
output "elb_subnet_b_id" { value = "${aws_subnet.elb_b.id}" }
output "elb_subnet_c_id" { value = "${aws_subnet.elb_c.id}" }
output "elb_subnet_az_a" { value = "${var.elb_subnet_az_a}" }
output "elb_subnet_az_b" { value = "${var.elb_subnet_az_b}" }
output "elb_subnet_az_c" { value = "${var.elb_subnet_az_c}" }