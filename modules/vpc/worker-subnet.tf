# subnet for worker cluster

variable "worker_subnet_a" { default = "10.0.200.0/24" }
variable "worker_subnet_b" { default = "10.0.201.0/24" }
variable "worker_subnet_c" { default = "10.0.202.0/24" }
variable "worker_subnet_az_a" { default = "us-west-2a" }
variable "worker_subnet_az_b" { default = "us-west-2b" }
variable "worker_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "worker_a" {
    vpc_id = "${aws_vpc.coreos_cluster.id}"
    availability_zone = "${var.worker_subnet_az_a}"
    cidr_block = "${var.worker_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "worker_a"
    }
}

resource "aws_route_table_association" "worker_rt_a" {
    subnet_id = "${aws_subnet.worker_a.id}"
    route_table_id = "${aws_route_table.coreos_cluster.id}"
}

resource "aws_subnet" "worker_b" {
    vpc_id = "${aws_vpc.coreos_cluster.id}"
    availability_zone = "${var.worker_subnet_az_b}"
    cidr_block = "${var.worker_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "worker_b"
    }
}

resource "aws_route_table_association" "worker_rt_b" {
    subnet_id = "${aws_subnet.worker_b.id}"
    route_table_id = "${aws_route_table.coreos_cluster.id}"
}

resource "aws_subnet" "worker_c" {
    vpc_id = "${aws_vpc.coreos_cluster.id}"
    availability_zone = "${var.worker_subnet_az_c}"
    cidr_block = "${var.worker_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "worker_c"
    }
}

resource "aws_route_table_association" "worker_rt_c" {
    subnet_id = "${aws_subnet.worker_c.id}"
    route_table_id = "${aws_route_table.coreos_cluster.id}"
}

output "worker_subnet_a_id" { value = "${aws_subnet.worker_a.id}" }
output "worker_subnet_b_id" { value = "${aws_subnet.worker_b.id}" }
output "worker_subnet_c_id" { value = "${aws_subnet.worker_c.id}" }
output "worker_subnet_az_a" { value = "${var.worker_subnet_az_a}" }
output "worker_subnet_az_b" { value = "${var.worker_subnet_az_b}" }
output "worker_subnet_az_c" { value = "${var.worker_subnet_az_c}" }