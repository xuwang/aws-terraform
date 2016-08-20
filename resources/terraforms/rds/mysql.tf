variable "mysql_db_user" { default = "root" }
variable "mysql_db_password" { default = "dbchangeme" }

resource "aws_db_instance" "cluster-mysql" {
    identifier = "${var.cluster_name}-mysql"
    allocated_storage = 10
    engine = "mysql"
    instance_class = "db.t2.medium"
    storage_type = "gp2"
    name = "master"
    username = "${var.mysql_db_user}"
    password = "${var.mysql_db_password}"
    multi_az = "false" 
    availability_zone = "${var.rds_subnet_a_az}"
    port = "3306"
    publicly_accessible = "false"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.cluster_db.id}"
}

# Register with Route53: 
#    create a db.app_domain zone, a star *.db.app_domain record, NS record in app_domain zone

# In private zone *.mysqldb.cluster.local
resource "aws_route53_record" "star_mysqldb_private" {
    zone_id = "${var.route53_private_zone_id}"
    name = "*.mysqldb"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.cluster-mysql.address}" ]
}

# mysql db NS delegation set
resource "aws_route53_delegation_set" "mysql-dns" {
    reference_name = "mysqlDNS"
    provisioner "local-exec" {
        command = "sleep ${var.wait_time}"
    }
}

# Create mysql db zone record
resource "aws_route53_zone" "cluster-mysqldb" {
    name = "mysqldb.${var.app_domain}"
    delegation_set_id = "${aws_route53_delegation_set.mysql-dns.id}"
}
# Create NS record in ${var.app_domain} zone
resource "aws_route53_record" "mysqldb" {
    zone_id = "${var.route53_public_zone_id}"
    name = "mysqldb.${var.app_domain}"
    type = "NS"
    ttl = "60"
    records = [
        "${aws_route53_zone.cluster-mysqldb.name_servers.0}",
        "${aws_route53_zone.cluster-mysqldb.name_servers.1}",
        "${aws_route53_zone.cluster-mysqldb.name_servers.2}",
        "${aws_route53_zone.cluster-mysqldb.name_servers.3}"
    ]
}

# Create star_mysqldb record set
resource "aws_route53_record" "star_mysqldb" {
    zone_id = "${aws_route53_zone.cluster-mysqldb.id}"
    name = "*.mysqldb.${var.app_domain}"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.cluster-mysql.address}" ]
}

output "mysql_db_password" {
    sensitive = true
    value = "${var.mysql_db_password}"
}
output "db_instance_cluster_mysql_address" {
    value = "${aws_db_instance.cluster-mysql.address}"
}
output "db_instance_cluster_mysql_endpoint" {
    value = "${aws_db_instance.cluster-mysql.endpoint}"
}
