variable "vault_release_url" {
  default = "https://releases.hashicorp.com/vault/0.6.4/vault_0.6.4_linux_amd64.zip"
}
variable "vault_cert" { default = "../certs/site.pem" }
variable "vault_cert_chain" { default = "../certs/rootCA.pem" }
variable "vault_cert_key" { default = "../certs/site-key.pem" }
#  Use TCP because we use TLS. 
variable "elb-health-check" {
    default = "TCP:8200"
    description = "Health check for Vault servers"
}

