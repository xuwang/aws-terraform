# s3 bucket requires gloable unique bucket name, make sure set a prefix bucket 
# to make the bucket name unique

variable "bucket_prefix" {
    default = "coreos-cluster"
}

# s3 bucket for initial-cluster etcd proxy discovery
# and two-stage cloudinit user-data files
resource "aws_s3_bucket" "cloudinit" {
    bucket = "${var.bucket_prefix}-cloudinit"
    acl = "private"
    force_destroy = true
    tags {
        Name = "Cloudinit"
    }
}
# s3 bucket for application configuration, code, units etcd. Shared by all cluster nodes
resource "aws_s3_bucket" "config" {
    bucket = "${var.bucket_prefix}-config"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Config"
    }
}

# s3 bucket for jenkins backup data
resource "aws_s3_bucket" "jenkins" {
    bucket = "${var.bucket_prefix}-jenkins"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Jenkins"
    }
}

# s3 bucket for private docker registry
resource "aws_s3_bucket" "dockerhub" {
    bucket = "${var.bucket_prefix}-dockerhub"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Dockerhub"
    }
}

# s3 bucket for log data backup
resource "aws_s3_bucket" "logs" {
    bucket = "${var.bucket_prefix}-logs"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Logs"
    }
}
