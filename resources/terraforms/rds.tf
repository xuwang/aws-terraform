variable "postgres_db_user" { default = "root" }
variable "postgres_db_password" { default = "dbchangeme" }
variable "mysql_db_user" { default = "root" }
variable "mysql_db_password" { default = "dbchangeme" }

resource "aws_db_subnet_group" "coreos_cluster_db" {
    name = "coreos-cluster-db"
    description = "db subnets for coreos-cluster applications"
    subnet_ids = ["${module.rds_subnet_a.id}","${module.rds_subnet_b.id}","${module.rds_subnet_c.id}"]
}

resource "aws_db_instance" "coreos_cluster-postgres" {
    identifier = "${var.cluster_name}-postgres"
    allocated_storage = 10
    engine = "postgres"
    engine_version = "9.5.2"
    instance_class = "db.t2.medium"
    storage_type = "gp2"
    name = "dockerage"
    username = "${var.postgres_db_user}"
    password = "${var.postgres_db_password}"
    multi_az = "false" 
    availability_zone = "${module.rds_subnet_a.az}"
    port = "5432"
    publicly_accessible = "false"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.coreos_cluster_db.id}"
}

/* Register with Route53
resource "aws_route53_record" "star_postgresdb" {
    zone_id = "${var.route53_private_zone_id}"
    name = "*.postgresdb"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.coreos_cluster-postgres.address}" ]
}
*/

resource "aws_db_instance" "coreos_cluster-mysql" {
    identifier = "${var.cluster_name}-mysql"
    allocated_storage = 10
    engine = "mysql"
    engine_version = "5.6.23"
    instance_class = "db.t2.micro"
    name = "dockerage"
    username = "root"
    password = "${var.postgres_db_password}"
    multi_az = "false"
    port = "3306"
    publicly_accessible = "true"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    availability_zone = "${module.rds_subnet_a.az}"
    storage_type="gp2"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
    db_subnet_group_name = "${aws_db_subnet_group.coreos_cluster_db.id}"
    parameter_group_name = "default.mysql5.6"
}

resource "aws_security_group" "rds"  {
    name = "rds"
    vpc_id = "${aws_vpc.cluster_vpc.id}"
    description = "rds SG"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow MySQL access
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["${aws_vpc.cluster_vpc.cidr_block}"]
    }
    # Allow PostgresSQL access
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      cidr_blocks = ["${aws_vpc.cluster_vpc.cidr_block}"]
    }
}