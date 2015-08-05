# subnet for rds cluster

variable "rds_subnet_a" { default = "10.0.40.0/24" }
variable "rds_subnet_b" { default = "10.0.41.0/24" }
variable "rds_subnet_c" { default = "10.0.42.0/24" }
variable "rds_subnet_az_a" { default = "us-west-2a" }
variable "rds_subnet_az_b" { default = "us-west-2b" }
variable "rds_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "rds_a" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.rds_subnet_az_a}"
    cidr_block = "${var.rds_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "rds_a"
    }
}

resource "aws_route_table_association" "rds_rt_a" {
    subnet_id = "${aws_subnet.rds_a.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "rds_b" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.rds_subnet_az_b}"
    cidr_block = "${var.rds_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "rds_b"
    }
}

resource "aws_route_table_association" "rds_rt_b" {
    subnet_id = "${aws_subnet.rds_b.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

resource "aws_subnet" "rds_c" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    availability_zone = "${var.rds_subnet_az_c}"
    cidr_block = "${var.rds_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "rds_c"
    }
}

resource "aws_route_table_association" "rds_rt_c" {
    subnet_id = "${aws_subnet.rds_c.id}"
    route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "rds_subnet_a_id" { value = "${aws_subnet.rds_a.id}" }
output "rds_subnet_b_id" { value = "${aws_subnet.rds_b.id}" }
output "rds_subnet_c_id" { value = "${aws_subnet.rds_c.id}" }
output "rds_subnet_az_a" { value = "${var.rds_subnet_az_a}" }
output "rds_subnet_az_b" { value = "${var.rds_subnet_az_b}" }
output "rds_subnet_az_c" { value = "${var.rds_subnet_az_c}" }