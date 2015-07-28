# Upload a example/demo wildcard cert

resource "aws_iam_server_certificate" "wildcard" {
  name = "wildcard"
  certificate_body = "${file("../tfcommon/certs/site.pem")}"
  certificate_chain = "${file("../tfcommon/certs/rootCA.pem")}"
  private_key = "${file("../tfcommon/certs/site-key.pem")}"

  provisioner "local-exec" {
    command = <<EOF
echo # Sleep 10 secends so that aws_iam_server_certificate.wildcard is truely setup by aws iam service
echo # See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)
sleep 10
EOF
  }
}
