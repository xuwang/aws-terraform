resource "aws_route53_zone" "public" {
    name = "${var.app_domain}"

    tags {
        Name = "${var.app_domain}"
    }
}

resource "aws_route53_zone" "private" {
    name = "${var.cluster_name}.cluster.local"   
    vpc_id = "${var.cluster_vpc_id}"

    tags {
        Name = "${var.cluster_name}.cluster.local"
    }
}

output "route53_public_zone_id"  { value = "${aws_route53_zone.public.id}" }
output "route53_private_zone_id" { value = "${aws_route53_zone.private.id}" }