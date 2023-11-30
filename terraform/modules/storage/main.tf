# Create an S3 Bucket
resource "aws_s3_bucket" "nxt_s3_bucket" {
  bucket = "nxt-bucket"

  tags = {
    Name = "nxt-bucket"
  }
}

# Define CORS Policy
resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.nxt_s3_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://nxt-app.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

# Define bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.nxt_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.nxt_s3_bucket.arn,
      "${aws_s3_bucket.nxt_s3_bucket.arn}/*",
    ]
  }
}
