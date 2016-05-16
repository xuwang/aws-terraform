resource "aws_db_subnet_group" "coreos_cluster" {
    name = "${var.cluster_name}-db"
    description = "db subnets for ${var.cluster_name} applications"
    # This placeholder will be replaced by array of variables defined for VPC zone IDs in the module's variables
    subnet_ids = <%MODULE-ID-VARIABLES-ARRAY%>
}

resource "aws_db_instance" "coreos_cluster" {
    identifier = "${var.cluster_name}"
    allocated_storage = 10
    engine = "postgres"
    engine_version = "9.3.5"
    instance_class = "db.t1.micro"
    storage_type = "gp2"
    name = "dockerage"
    username = "${var.db_user}"
    password = "${var.db_password}"
    multi_az = "false"
    availability_zone = "${var.rds_subnet_az_b}"
    port = "5432"
    publicly_accessible = "false"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.coreos_cluster.id}"
}

/* bug - tfp wanted to re-created the record.
resource "aws_route53_record" "star_postgresdb" {
    zone_id = "${var.route53_private_zone_id}"
    name = "*.postgresdb"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.coreos_cluster.address}" ]
}
*/
