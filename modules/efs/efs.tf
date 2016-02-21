# EFS cluster
resource "aws_efs_file_system" "efs" {
  reference_name = "${var.platform}-efs"
  tags {
    Name = "${var.platform}-efs"
  }
  tags {
    Billing = "${var.platform}"
  }
}

resource "aws_efs_mount_target" "efs-a" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.efs_subnet_a_id}"
  security_groups = ["${aws_security_group.efs}"]
}
resource "aws_efs_mount_target" "efs-b" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.efs_subnet_b_id}"
  security_groups = ["${aws_security_group.efs}"]
}
resource "aws_efs_mount_target" "efs-c" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id = "${var.efs_subnet_c_id}"
  security_groups = ["${aws_security_group.efs}"]
}

output "aws-efs-file-system-efs-id" {
    value = "${aws_efs_file_system.efs.id}"
}
