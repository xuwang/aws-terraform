module "elb" {
    source = "../modules/elb"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"
    elb_subnet_a_id = "${module.vpc.elb_subnet_a_id}"
    elb_subnet_b_id = "${module.vpc.elb_subnet_b_id}"
    elb_subnet_c_id = "${module.vpc.elb_subnet_c_id}"
    elb_subnet_az_a = "${module.vpc.elb_subnet_az_a}"
    elb_subnet_az_b = "${module.vpc.elb_subnet_az_b}"
    elb_subnet_az_c = "${module.vpc.elb_subnet_az_c}"

    # route53
    #route53_public_zone_id = "${module.route53.public_zone_id}"
    #route53_private_zone_id = "${module.route53.private_zone_id}"
    route53_public_zone_id = "not_available"
    route53_private_zone_id = "not_available"
}