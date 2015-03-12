resource "aws_instance" "etcd-c-01" {
    #depends_on = [ "aws_instance.etcd-a-01" ]
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "${var.aws_instance_type}"
    block_device = {
        device_name = "/dev/sdb"
        volume_type = "gp2"
        volume_size = "50"
    }
    key_name = "${var.aws_ec2_keypair.etcd}"
    security_groups = [ "${var.security_group_etcd}" ]
    private_ip = "${var.etcd_private_ip.us-west-2c}"
    subnet_id = "${var.subnet_core-us-west-2c}"
    iam_instance_profile = "${var.iam_instance_profile.etcd}"
    user_data = <<USER_DATA
${file("cloud-config/etcd-c-01.yaml")}
${file("../../common/cloud-config/systemd-units.yaml")}
${file("../../common/cloud-config/files.yaml")}
USER_DATA

    tags {
        Name="docker-etcd-c-01"
    }
}

