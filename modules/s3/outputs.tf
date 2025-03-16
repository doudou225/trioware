output "new_bucket" {
  value = aws_s3_bucket.my-bucket.bucket
}

output "sophos_url_windows" {
  value = "https://${aws_s3_bucket.my-bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.sophos_windows.key}"
}

output "sophos_url_linux" {
  value = "https://${aws_s3_bucket.my-bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.sophos_linux.key}"
}

output "rapid7_url_windows" {
  value = "https://${aws_s3_bucket.my-bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.rapid7_windows.key}"
}

output "rapid7_url_linux_x64_deb" {
  value = "https://${aws_s3_bucket.my-bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.rapid7_linux_x64_deb.key}"
}

output "pmp_url_windows" {
  value = "https://${aws_s3_bucket.my-bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.pmp_windows.key}"
}

output "pmp_url_linux" {
  value = "https://${aws_s3_bucket.my-bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.pmp_linux.key}"
}

