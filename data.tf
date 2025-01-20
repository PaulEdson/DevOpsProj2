data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.s3-bucket.arn,
      "${aws_s3_bucket.s3-bucket.arn}/*",
    ]
  }
}