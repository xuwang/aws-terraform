module "rds_subnet_a" {
  source = "../modules/subnet"

  subnet_name = "rds_a"
  subnet_cidr = "10.10.4.0/26"
  subnet_az = "us-west-2a"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "rds_subnet_b" {
  source = "../modules/subnet"

  subnet_name = "rds_b"
  subnet_cidr = "10.10.4.64/26"
  subnet_az = "us-west-2b"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "rds_subnet_c" {
  source = "../modules/subnet"

  subnet_name = "rds_c"
  subnet_cidr = "10.10.4.128/26"
  subnet_az = "us-west-2c"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}