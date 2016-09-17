resource "aws_cloudtrail" "cluster_cloudtrail" {
    name = "${var.trail_name}"
    s3_bucket_name = "${aws_s3_bucket.cluster_cloudtrail.id}"
    include_global_service_events = "${var.include_global_service_events}"
    is_multi_region_trail = "${var.is_multi_region_trail}"
    #sns_topic_name = "${var.sns_topic_name}"
    tags {
        Name = "${var.trail_name}"
    }
}

resource "aws_s3_bucket" "cluster_cloudtrail" {
    bucket = "${var.s3_bucket_name}"
    force_destroy = true
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.cluster_name}-cloudtrail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.cluster_name}-cloudtrail/AWSLogs/${var.aws_account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
