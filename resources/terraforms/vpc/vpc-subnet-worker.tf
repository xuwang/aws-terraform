module "worker_subnet_a" {
  source = "../../modules/subnet"

  subnet_name = "worker_a"
  subnet_cidr = "10.10.5.0/26"
  subnet_az = "us-west-2a"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "worker_subnet_b" {
  source = "../../modules/subnet"

  subnet_name = "worker_b"
  subnet_cidr = "10.10.5.64/26"
  subnet_az = "us-west-2b"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "worker_subnet_c" {
  source = "../../modules/subnet"

  subnet_name = "worker_c"
  subnet_cidr = "10.10.5.128/26"
  subnet_az = "us-west-2c"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "worker_subnet_a_id" { value = "${module.worker_subnet_a.id}" }
output "worker_subnet_a_az" { value = "${module.worker_subnet_a.az}" }
output "worker_subnet_b_id" { value = "${module.worker_subnet_b.id}" }
output "worker_subnet_b_az" { value = "${module.worker_subnet_b.az}" }
output "worker_subnet_c_id" { value = "${module.worker_subnet_c.id}" }
output "worker_subnet_c_az" { value = "${module.worker_subnet_c.az}" }