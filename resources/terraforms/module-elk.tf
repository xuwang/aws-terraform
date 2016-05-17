module "elk" {
    source = "../modules/elk"

    image_type = "t2.micro"
    cluster_desired_capacity = 1
    root_volume_size =  8
    docker_volume_size =  12
    keypair = "elk"
    allow_ssh_cidr="0.0.0.0/0"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "${var.aws_account.default_region}"
    ami = "${var.ami}"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"

    # This placeholder will be replaced by ADMIRAL subnet id and availability zone variables
    # For more information look into 'substitute-VPC-AZ-placeholders.sh'
    
		elk_subnet_a_id = "${module.vpc.admiral_subnet_a_id}"
		elk_subnet_b_id = "${module.vpc.admiral_subnet_b_id}"
	
		elk_subnet_az_a = "${module.vpc.admiral_subnet_az_a}"
		elk_subnet_az_b = "${module.vpc.admiral_subnet_az_b}"
}
