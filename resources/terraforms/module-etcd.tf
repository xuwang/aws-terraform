module "etcd" {
    source = "../modules/etcd"

    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"
    vpc_route_table = "${module.vpc.vpc_route_table}"
    allow_ssh_cidr="0.0.0.0/0"
    aws_account_id="${var.aws_account.id}"
    aws_region = "us-west-2"
    ami = "${lookup(var.amis, "us-west-2")}"
    keypair = "etcd"
    build_dir = "${var.build_dir}"

    # etcd cluster_desired_capacity should be in odd numbers, e.g. 3, 5, 9
    cluster_desired_capacity = 1
    image_type = "t2.micro"
}