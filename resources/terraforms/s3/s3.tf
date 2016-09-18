# s3 bucket for initial-cluster etcd proxy discovery
# and two-stage cloudinit user-data files
resource "aws_s3_bucket" "cloudinit" {
    bucket = "${var.aws_account["id"]}-${var.cluster_name}-cloudinit"
    acl = "private"
    force_destroy = true
    tags {
        Name = "Cloudinit"
    }
}
# s3 bucket for application configuration, code, units etcd. Shared by all cluster nodes
resource "aws_s3_bucket" "config" {
    bucket = "${var.aws_account["id"]}-${var.cluster_name}-config"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Config"
    }
}

# s3 bucket for jenkins backup data
resource "aws_s3_bucket" "jenkins" {
    bucket = "${var.aws_account["id"]}-${var.cluster_name}-jenkins"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Jenkins"
    }
}

# s3 bucket for private docker registry
resource "aws_s3_bucket" "dockerhub" {
    bucket = "${var.aws_account["id"]}-${var.cluster_name}-dockerhub"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Dockerhub"
    }
}

# s3 bucket for log data backup
resource "aws_s3_bucket" "logs" {
    bucket = "${var.aws_account["id"]}-${var.cluster_name}-logs"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Logs"
    }
}

output "s3_cloudinit_bucket" { value = "${aws_s3_bucket.cloudinit.id}" }
output "s3_config_bucket" { value = "${aws_s3_bucket.config.id}" }
output "s3_jenkins_bucket" { value = "${aws_s3_bucket.jenkins.id}" }
output "s3_dockerhub_bucket" { value = "${aws_s3_bucket.dockerhub.id}" }
output "s3_logs_bucket" { value = "${aws_s3_bucket.logs.id}" }