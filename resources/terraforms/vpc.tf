
resource "aws_vpc" "cluster_vpc" {
    cidr_block = "10.10.0.0/16"
    tags {
        Name = "${var.cluster_name}"
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
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.cluster_vpc.id}"
    }
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    service_name = "com.amazonaws.${var.aws_account.default_region}.s3"
    route_table_ids = ["${aws_route_table.cluster_vpc.id}"]
}