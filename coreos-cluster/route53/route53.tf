resource "aws_route53_zone" "primary" {
    name = "dockerage.com"
    provisioner "local-exec" {
    command = <<CMD_DATA
cat >> ../tfcommon/route53.tfvars <<TFVARS
# Generated main hosted zone id
aws_route53_zone_id_primary  = "${aws_route53_zone.primary.zone_id}"
TFVARS
CMD_DATA
    }
}

