module "worker" {
    source = "../modules/worker"

    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"
    vpc_route_table = "${module.vpc.vpc_route_table}"
    allow_ssh_cidr="0.0.0.0/0"
    aws_account_id="${var.aws_account.id}"
    aws_region = "us-west-2"
    ami = "${lookup(var.amis, "us-west-2")}"
    keypair = "worker"
    image_type = "t2.micro"
    cluster_desired_capacity = 1
    root_volume_size =  8
    ebs_volume_size =  12
}