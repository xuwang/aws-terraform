resource "aws_route53_zone" "primary" {
    name = "${var.project_tags.public_domain}"

    tags {
        Name = "dockerage.com"
    }

    provisioner "local-exec" {
    command = <<CMD_DATA
cat > ../tfcommon/route53-vars.tfvars <<TFVARS
# Generated primary zone id
aws_route53_primary_zone_id  = "${aws_route53_zone.primary.zone_id}"
TFVARS
CMD_DATA
    }
}

resource "aws_route53_zone" "private" {
    name = "${var.project_tags.private_domain}"
    
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "coreos-cluster.local"
        Billing = "${var.project_tags.coreos_cluster}"
    }

    provisioner "local-exec" {
    command = <<CMD_DATA
cat >> ../tfcommon/route53-vars.tfvars <<TFVARS
# Generated private zone id
aws_route53_private_zone_id  = "${aws_route53_zone.private.zone_id}"
TFVARS
CMD_DATA
    }
}


