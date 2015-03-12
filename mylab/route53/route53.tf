resource "aws_route53_zone" "primary" {
    name = "mylab.example.com"
    provisioner "local-exec" {
    command = <<CMD_DATA
cat >> ../tfcommon/route53.tfvars <<TFVARS
# main hosted zone id
aws_route53_zone_id_primary  = \"${aws_route53_zone.primary.zone_id}\"
TFVARS
CMD_DATA
    }
}

resource "aws_route53_zone" "mylab-db" {
    name = "db.mylab.example.com"
    provisioner "local-exec" {
    command = <<CMD_DATA
cat >> ../tfcommon/route53.tfvars <<TFVARS
# db hosted zone id
aws_route53_zone_id_db = \"${aws_route53_zone.mylab-db.zone_id}\"
TFVARS
CMD_DATA
    }
}

resource "aws_route53_zone" "mylab-postgresdb" {
    name = "postgresdb.mylab.example.com"
    provisioner "local-exec" {
    command = <<CMD_DATA
cat >> ../tfcommon/route53.tfvars <<TFVARS
# db hosted zone id
aws_route53_zone_id_postgresdb = ${aws_route53_zone.mylab-postgresdb.zone_id}
TFVARS
CMD_DATA
    }
}
