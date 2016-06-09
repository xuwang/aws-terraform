module "admiral_subnet_a" {
  source = "../modules/subnet"

  subnet_name = "admiral_a"
  subnet_cidr = "10.10.2.0/26"
  subnet_az = "us-west-2a"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "admiral_subnet_b" {
  source = "../modules/subnet"

  subnet_name = "admiral_b"
  subnet_cidr = "10.10.2.64/26"
  subnet_az = "us-west-2b"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "admiral_subnet_c" {
  source = "../modules/subnet"

  subnet_name = "admiral_c"
  subnet_cidr = "10.10.2.128/26"
  subnet_az = "us-west-2c"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}