variable "vault_release_url" {
  default = "https://releases.hashicorp.com/vault/0.6.1/vault_0.6.1_linux_amd64.zip"
}
variable "vault_cert" { default = "../certs/site.pem" }
variable "vault_cert_chain" { default = "../certs/rootCA.pem" }
variable "vault_cert_key" { default = "../certs/site-key.pem" }
variable "elb-health-check" {
    default = "HTTP:8200/v1/sys/health"
    description = "Health check for Vault servers"
}

