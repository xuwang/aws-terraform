module "admiral_subnet_0" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-admiral_0"
  subnet_cidr = "10.10.2.0/26"
  subnet_az = "${data.aws_availability_zones.available.names[0]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "admiral_subnet_1" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-admiral_1"
  subnet_cidr = "10.10.2.64/26"
  subnet_az = "${data.aws_availability_zones.available.names[1]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "admiral_subnet_2" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-admiral_2"
  subnet_cidr = "10.10.2.128/26"
  subnet_az = "${data.aws_availability_zones.available.names[2]}"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "admiral_subnet_0_id" { value = "${module.admiral_subnet_0.id}" }
output "admiral_subnet_0_az" { value = "${module.admiral_subnet_0.az}" }
output "admiral_subnet_1_id" { value = "${module.admiral_subnet_1.id}" }
output "admiral_subnet_1_az" { value = "${module.admiral_subnet_1.az}" }
output "admiral_subnet_2_id" { value = "${module.admiral_subnet_2.id}" }
output "admiral_subnet_2_az" { value = "${module.admiral_subnet_2.az}" }