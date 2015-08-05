# subnet for etcd cluster

variable "etcd_subnet_a" { default = "10.0.1.0/26" }
variable "etcd_subnet_b" { default = "10.0.1.64/26" }
variable "etcd_subnet_c" { default = "10.0.1.128/26" }
variable "etcd_subnet_az_a" { default = "us-west-2a" }
variable "etcd_subnet_az_b" { default = "us-west-2b" }
variable "etcd_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "etcd_a" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.etcd_subnet_az_a}"
    cidr_block = "${var.etcd_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "etcd_a"
    }
}

resource "aws_route_table_association" "etcd_rt_a" {
    subnet_id = "${aws_subnet.etcd_a.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "etcd_b" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.etcd_subnet_az_b}"
    cidr_block = "${var.etcd_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "etcd_b"
    }
}

resource "aws_route_table_association" "etcd_rt_b" {
    subnet_id = "${aws_subnet.etcd_b.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "etcd_c" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.etcd_subnet_az_c}"
    cidr_block = "${var.etcd_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "etcd_c"
    }
}

resource "aws_route_table_association" "etcd_rt_c" {
    subnet_id = "${aws_subnet.etcd_c.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "etcd_subnet_a_id" { value = "${aws_subnet.etcd_a.id}" }
output "etcd_subnet_b_id" { value = "${aws_subnet.etcd_b.id}" }
output "etcd_subnet_c_id" { value = "${aws_subnet.etcd_c.id}" }
output "etcd_subnet_az_a" { value = "${var.etcd_subnet_az_a}" }
output "etcd_subnet_az_b" { value = "${var.etcd_subnet_az_b}" }
output "etcd_subnet_az_c" { value = "${var.etcd_subnet_az_c}" }