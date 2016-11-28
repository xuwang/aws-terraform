module "worker_subnet_0" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-worker_0"
  subnet_cidr = "10.10.5.0/26"
  subnet_az = "${data.aws_availability_zones.available.names[0]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "worker_subnet_1" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-worker_1"
  subnet_cidr = "10.10.5.64/26"
  subnet_az = "${data.aws_availability_zones.available.names[1]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "worker_subnet_2" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-worker_2"
  subnet_cidr = "10.10.5.128/26"
  subnet_az = "${data.aws_availability_zones.available.names[2]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "worker_subnet_0_id" { value = "${module.worker_subnet_0.id}" }
output "worker_subnet_0_az" { value = "${module.worker_subnet_0.az}" }
output "worker_subnet_1_id" { value = "${module.worker_subnet_1.id}" }
output "worker_subnet_1_az" { value = "${module.worker_subnet_1.az}" }
output "worker_subnet_2_id" { value = "${module.worker_subnet_2.id}" }
output "worker_subnet_2_az" { value = "${module.worker_subnet_2.az}" }