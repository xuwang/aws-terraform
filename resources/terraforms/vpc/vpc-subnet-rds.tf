module "rds_subnet_0" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-rds_0"
  subnet_cidr = "10.10.4.0/26"
  subnet_az = "${data.aws_availability_zones.available.names[0]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "rds_subnet_1" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-rds_1"
  subnet_cidr = "10.10.4.64/26"
  subnet_az = "${data.aws_availability_zones.available.names[1]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "rds_subnet_2" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-rds_2"
  subnet_cidr = "10.10.4.128/26"
  subnet_az = "${data.aws_availability_zones.available.names[2]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "rds_subnet_0_id" { value = "${module.rds_subnet_0.id}" }
output "rds_subnet_0_az" { value = "${module.rds_subnet_0.az}" }
output "rds_subnet_1_id" { value = "${module.rds_subnet_1.id}" }
output "rds_subnet_1_az" { value = "${module.rds_subnet_1.az}" }
output "rds_subnet_2_id" { value = "${module.rds_subnet_2.id}" }
output "rds_subnet_2_az" { value = "${module.rds_subnet_2.az}" }