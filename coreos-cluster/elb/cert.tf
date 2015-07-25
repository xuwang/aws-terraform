# Upload a example/demo wildcard cert

resource "aws_iam_server_certificate" "wildcard" {
  name = "wildcard"
  certificate_body = "${file("../tfcommon/certs/site.pem")}"
  certificate_chain = "${file("../tfcommon/certs/rootCA.pem")}"
  private_key = "${file("../tfcommon/certs/site-key.pem")}"
}
