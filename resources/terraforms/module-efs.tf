module "efs" {
    source = "../modules/efs"
    vpc_id = "${module.vpc.vpc_id}"
    vpc_name = "${var.cluster_name}"
    efs_subnet_a_id = "${module.vpc.worker_subnet_a_id}"
    efs_subnet_b_id = "${module.vpc.worker_subnet_b_id}"
    efs_subnet_c_id = "${module.vpc.worker_subnet_c_id}"
}
