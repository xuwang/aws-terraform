# EFS mount targets

variable "efs_subnet_a_id" { }
variable "efs_subnet_b_id" { }
variable "efs_subnet_c_id" { }

resource "aws_efs_mount_target" "efs-a" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.efs_subnet_a_id}"
  security_groups = ["${aws_security_group.efs.id}"]
}
resource "aws_efs_mount_target" "efs-b" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.efs_subnet_b_id}"
  security_groups = ["${aws_security_group.efs.id}"]
}
resource "aws_efs_mount_target" "efs-c" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.efs_subnet_c_id}"
  security_groups = ["${aws_security_group.efs.id}"]
}

output "aws-efs-file-system-efs-id" {
    value = "${aws_efs_file_system.efs.id}"
}
