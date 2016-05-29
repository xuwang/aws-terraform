module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.10.0.0/16"
    vpc_name = "${var.cluster_name}"
    vpc_region = "${var.aws_account.default_region}"

    # Override the default configuration. See ../modules/vpc for default values
    etcd_subnet_a = "10.10.1.0/26"
    etcd_subnet_b = "10.10.1.64/26"
    etcd_subnet_c = "10.10.1.128/26"

    admiral_subnet_a = "10.10.2.0/26"
    admiral_subnet_b = "10.10.2.64/26"
    admiral_subnet_c = "10.10.2.128/26"

    elb_subnet_a = "10.10.3.0/26"
    elb_subnet_b = "10.10.3.64/26"
    elb_subnet_c = "10.10.3.128/26"

    rds_subnet_a = "10.10.4.0/26"
    rds_subnet_b = "10.10.4.64/26"
    rds_subnet_c = "10.10.4.128/26"

    worker_subnet_a = "10.10.5.0/26"
    worker_subnet_b = "10.10.5.64/26"
    worker_subnet_c = "10.10.5.128/26"

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
