# EFS mount targets

variable "efs_subnet_0_id" { }
variable "efs_subnet_1_id" { }
variable "efs_subnet_2_id" { }
variable "filesystem_id" { }
variable "security_group_id" { }

resource "aws_efs_mount_target" "efs-a" {
  file_system_id = "${var.filesystem_id}"
  subnet_id = "${var.efs_subnet_0_id}"
  security_groups = ["${var.security_group_id}"]
}
resource "aws_efs_mount_target" "efs-b" {
  file_system_id = "${var.filesystem_id}"
  subnet_id = "${var.efs_subnet_1_id}"
  security_groups = ["${var.security_group_id}"]
}
resource "aws_efs_mount_target" "efs-c" {
  file_system_id = "${var.filesystem_id}"
  subnet_id = "${var.efs_subnet_2_id}"
  security_groups = ["${var.security_group_id}"]
}
