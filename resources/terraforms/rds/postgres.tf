variable "postgres_db_user" { default = "root" }
variable "postgres_db_password" { default = "dbchangeme" }

resource "aws_db_instance" "cluster-postgres" {
    identifier = "${var.cluster_name}-postgres"
    allocated_storage = 10
    engine = "postgres"
    #engine_version = "9.5.2"
    instance_class = "db.t2.medium"
    storage_type = "gp2"
    name = "master"
    username = "${var.postgres_db_user}"
    password = "${var.postgres_db_password}"
    multi_az = "false" 
    availability_zone = "${var.rds_subnet_0_az}"
    port = "5432"
    publicly_accessible = "true"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:10"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.cluster_db.id}"
}

# Register with Route53
# Create record in ${var.app_domain} zone
resource "aws_route53_record" "postgresdb" {
    zone_id = "${var.route53_public_zone_id}"
    name = "postgresdb.${var.app_domain}"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.cluster-postgres.address}" ]
}

output "db_instance_cluster_postgres_name" {
    value = "${aws_db_instance.cluster-postgres.name}"
}
output "db_instance_cluster_postgres_username" {
    value = "${aws_db_instance.cluster-postgres.username}"
}
output "postgres_db_password" {
    sensitive = true
    value = "${var.postgres_db_password}"
}
output "db_instance_cluster_postgres_address" {
    value = "${aws_db_instance.cluster-postgres.address}"
}
output "db_instance_cluster_postgres_endpoint" {
    value = "${aws_db_instance.cluster-postgres.endpoint}"
}
