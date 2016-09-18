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
    publicly_accessible = "true"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:10"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.cluster_db.id}"
}

# Register with Route53

# Create record in ${var.app_domain} zone
resource "aws_route53_record" "mysqldb" {
    zone_id = "${var.route53_public_zone_id}"
    name = "mysqldb.${var.app_domain}"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.cluster-mysql.address}" ]
}

output "db_instance_cluster_mysql_name" {
    value = "${aws_db_instance.cluster-mysql.name}"
}
output "db_instance_cluster_mysql_username" {
    value = "${aws_db_instance.cluster-mysql.username}"
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