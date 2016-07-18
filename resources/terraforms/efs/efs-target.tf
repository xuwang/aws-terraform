module "efs-target" {
    source = "../../modules/efs-target"
    filesystem_id = "${var.efs_file_system_efs_id}"
    security_group_id = "${var.security_group_efs_id}"
    efs_subnet_a_id = "${var.worker_subnet_a_id}"
    efs_subnet_b_id = "${var.worker_subnet_b_id}"
    efs_subnet_c_id = "${var.worker_subnet_c_id}"
}