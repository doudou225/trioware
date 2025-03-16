data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


locals {
  bucket_name = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-dcops"
}


resource "aws_s3_bucket" "my-bucket" {
  bucket = local.bucket_name
  tags = {
    owner = "dcops"
  }

}


resource "aws_s3_bucket_policy" "allow_access_from_ou" {
  bucket = aws_s3_bucket.my-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_ou.json
}


data "aws_iam_policy_document" "allow_access_from_ou" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.my-bucket.arn}",
      "${aws_s3_bucket.my-bucket.arn}/*"
    ]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["o-0nv3gdkksw/*"]
    }
  }

}

resource "aws_s3_object" "sophos_windows" {
  bucket = aws_s3_bucket.my-bucket.bucket
  key    = "SophosSetup.exe"
  source = var.source_sophos_windows
}

resource "aws_s3_object" "sophos_linux" {
  bucket = aws_s3_bucket.my-bucket.bucket
  key    = "SophosSetup.sh"
  source = var.source_sophos_linux
}


resource "aws_s3_object" "rapid7_windows" {
  bucket = aws_s3_bucket.my-bucket.bucket
  key    = "agentInstaller-x86_64.msi"
  source = var.source_r7_windows
}

resource "aws_s3_object" "rapid7_linux_x64_deb" {
  bucket = aws_s3_bucket.my-bucket.bucket
  key    = "rapid7-insight-agent-${var.r7_linux_version}-1.amd64.deb"
  source = var.source_r7_deb_linux_x64
}


resource "aws_s3_object" "pmp_windows" {
  bucket = aws_s3_bucket.my-bucket.bucket
  key    = "pmp.zip"
  source = var.source_pmp_windows
}

resource "aws_s3_object" "pmp_linux" {
  bucket = aws_s3_bucket.my-bucket.bucket
  key    = "pmp_linux.zip"
  source = var.source_pmp_linux
}


