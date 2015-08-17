resource "aws_vpc_endpoint" "s3" {
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    service_name = "com.amazonaws.${var.vpc_region}.s3"
    route_table_ids = ["${aws_route_table.cluster_vpc.id}"]
}

output "endpoint-s3" { value = "${aws_vpc_endpoint.s3.id}" }