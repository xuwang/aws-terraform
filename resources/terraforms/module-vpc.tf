module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "${var.cluster_name}"
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
}
