resource "aws_db_subnet_group" "mylab-db" {
    name = "mylab-db"
    description = "main db group of subnets"
    subnet_ids = [ "${var.subnet_rds-us-west-2a}", "${var.subnet_rds-us-west-2b}", "${var.subnet_rds-us-west-2c}" ]
}
resource "aws_db_instance" "mylab-postgres" {
    identifier = "mylab-postgres"
    allocated_storage = 10
    engine = "postgres"
    engine_version = "9.3.5"
    instance_class = "db.t1.micro"
    name = "mylab"
    username = "root"
    password = "iey6aiLei1"
    multi_az = "false" 
    availability_zone = "us-west-2b"
    port = "5432"
    publicly_accessible = "true"
    backup_retention_period = "7"
    maintenance_window = "tue:10:33-tue:11:03"
    backup_window = "09:19-10:19"
    vpc_security_group_ids = ["${var.security_group_rds}"]
    db_subnet_group_name = "${aws_db_subnet_group.mylab-db.id}"

    provisioner "local-exec" {
         command = <<CMD_DATA
aws --profile mylab rds modify-db-instance --storage-type=gp2 --db-instance-identifier="${aws_db_instance.mylab-postgres.identifier}"
CMD_DATA
    }
}

/* bug - tfp wanted to re-created the record.
resource "aws_route53_record" "star_postgresdb" {
    zone_id = "${var.aws_route53_zone_id_postgresdb}"
    name = "*.postgresdb.mylab.example.com"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_db_instance.mylab-postgres.address}" ]
}
*/
