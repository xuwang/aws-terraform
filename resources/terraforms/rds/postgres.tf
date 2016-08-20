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
    availability_zone = "${var.rds_subnet_a_az}"
    port = "5432"
    publicly_accessible = "false"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.cluster_db.id}"
}

#Register with Route53
resource "aws_route53_record" "star_postgresdb_private" {
    zone_id = "${var.route53_private_zone_id}"
    name = "*.postgresdb"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.cluster-postgres.address}" ]
}

# PostgresSQL
resource "aws_route53_delegation_set" "postgres-dns" {
    reference_name = "PostgresDNS"
    provisioner "local-exec" {
        command = "sleep ${var.wait_time}"
    }
}

# Create postgresdb zone record
resource "aws_route53_zone" "cluster-postgresdb" {
    name = "postgresdb.${var.app_domain}"
    delegation_set_id = "${aws_route53_delegation_set.postgres-dns.id}"
}
# Create NS record in ${var.app_domain} zone
resource "aws_route53_record" "postgresdb" {
    zone_id = "${var.route53_public_zone_id}"
    name = "postgresdb.${var.app_domain}"
    type = "NS"
    ttl = "60"
    records = [
        "${aws_route53_zone.cluster-postgresdb.name_servers.0}",
        "${aws_route53_zone.cluster-postgresdb.name_servers.1}",
        "${aws_route53_zone.cluster-postgresdb.name_servers.2}",
        "${aws_route53_zone.cluster-postgresdb.name_servers.3}"
    ]
}

# Create star_postgresdb record set
resource "aws_route53_record" "star_postgresdb" {
    zone_id = "${aws_route53_zone.cluster-postgresdb.id}"
    name = "*.postgresdb.${var.app_domain}"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.cluster-postgres.address}" ]
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
