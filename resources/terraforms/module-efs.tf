module "efs" {
    source = "../modules/efs"
    efs_subnet_a_id = "${module.vpc.worker_subnet_a_id}"
    efs_subnet_b_id = "${module.vpc.worker_subnet_b_id}"
    efs_subnet_c_id = "${module.vpc.worker_subnet_c_id}"
}
