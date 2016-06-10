module "efs-target" {
    source = "../modules/efs-target"
    filesystem_id = "${aws_efs_file_system.efs.id}"
    security_group_id = "${aws_security_group.efs.id}"
    efs_subnet_a_id = "${module.worker_subnet_a.id}"
    efs_subnet_b_id = "${module.worker_subnet_b.id}"
    efs_subnet_c_id = "${module.worker_subnet_c.id}"
}