
resource "aws_vpc" "cluster_vpc" {
    cidr_block = "${var.vpc_cidr}"
    tags {
        Name = "${var.vpc_name}"
    }
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cluster_vpc" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
}

resource "aws_route_table" "cluster_vpc" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    route {
        cidr_block = "${var.all_net}"
        gateway_id = "${aws_internet_gateway.cluster_vpc.id}"
    }
}

output "vpc_id" {
    value = "${aws_vpc.cluster_vpc.id}"
}

output "vpc_cidr" {
    value = "${var.vpc_cidr}"
}

output "vpc_route_table" {
    value = "${aws_route_table.cluster_vpc.id}"
}

output "vpc_gateway" {
    value = "${aws_internet_gateway.cluster_vpc.id}"
}
