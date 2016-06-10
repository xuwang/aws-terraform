module "efs" {
    source = "../modules/efs"
    vpc_name = "${var.cluster_name}"
    efs_subnet_a_id = "${module.worker_subnet_a_id}"
    efs_subnet_b_id = "${module.worker_subnet_b_id}"
    efs_subnet_c_id = "${module.worker_subnet_c_id}"
}
