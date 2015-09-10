module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "${var.cluster_name}"
    vpc_region = "${var.aws_account.default_region}"
    
/*
# the following can be configured. See ../modules/vpc for default values
    etcd_subnet_a = <cdir value>
    etcd_subnet_b = <cdir value>
    etcd_subnet_c = <cdir value>

    admiral_subnet_a = <cdir value>
    admiral_subnet_b = <cdir value>
    admiral_subnet_c = <cdir value>
    
    worker_subnet_a = <cdir value>
    worker_subnet_b = <cdir value>
    worker_subnet_c = <cdir value>

    elb_subnet_a = <cdir value>
    elb_subnet_b = <cdir value>
    elb_subnet_c = <cdir value>

    rds_subnet_a = <cdir value>
    rds_subnet_b = <cdir value>
    rds_subnet_c = <cdir value>
*/


    etcd_subnet_az_a  = "${var.aws_account.default_region}a"
    etcd_subnet_az_b  = "${var.aws_account.default_region}b"
    etcd_subnet_az_c  = "${var.aws_account.default_region}c"

    admiral_subnet_az_a  = "${var.aws_account.default_region}a"
    admiral_subnet_az_b  = "${var.aws_account.default_region}b"
    admiral_subnet_az_c  = "${var.aws_account.default_region}c"

    worker_subnet_az_a  = "${var.aws_account.default_region}a"
    worker_subnet_az_b  = "${var.aws_account.default_region}b"
    worker_subnet_az_c  = "${var.aws_account.default_region}c"

    elb_subnet_az_a  = "${var.aws_account.default_region}a"
    elb_subnet_az_b  = "${var.aws_account.default_region}b"
    elb_subnet_az_c  = "${var.aws_account.default_region}c"

    rds_subnet_az_a  = "${var.aws_account.default_region}a"
    rds_subnet_az_b  = "${var.aws_account.default_region}b"
    rds_subnet_az_c  = "${var.aws_account.default_region}c"
}
