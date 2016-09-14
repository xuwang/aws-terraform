module "vault_subnet_a" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-vault_a"
  subnet_cidr = "10.10.6.0/26"
  subnet_az = "us-west-2a"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "vault_subnet_b" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-vault_b"
  subnet_cidr = "10.10.6.64/26"
  subnet_az = "us-west-2b"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

module "vault_subnet_c" {
  source = "../../modules/subnet"

  subnet_name = "${var.cluster_name}-vault_c"
  subnet_cidr = "10.10.6.128/26"
  subnet_az = "us-west-2c"
  vpc_id = "${aws_vpc.cluster_vpc.id}"
  route_table_id = "${aws_route_table.cluster_vpc.id}"
}

output "vault_subnet_a_id" { value = "${module.vault_subnet_a.id}" }
output "vault_subnet_a_az" { value = "${module.vault_subnet_a.az}" }
output "vault_subnet_b_id" { value = "${module.vault_subnet_b.id}" }
output "vault_subnet_b_az" { value = "${module.vault_subnet_b.az}" }
output "vault_subnet_c_id" { value = "${module.vault_subnet_c.id}" }
output "vault_subnet_c_az" { value = "${module.vault_subnet_c.az}" }