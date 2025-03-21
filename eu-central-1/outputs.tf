output "new_bucket_name" {
  value = module.create_s3_bucket.new_bucket

}

output "url_sophos_windows" {
  value = module.create_s3_bucket.sophos_url_windows
}

output "url_rapid7_windows" {
  value = module.create_s3_bucket.rapid7_url_windows
}

output "url_rapid7_linux_x64_deb" {
  value = module.create_s3_bucket.rapid7_url_linux_x64_deb
}

output "url_pmp_windows" {
  value = module.create_s3_bucket.pmp_url_windows
}

output "url_pmp_linux" {
  value = module.create_s3_bucket.pmp_url_linux
}


output "url_sophos_linux" {
  value = module.create_s3_bucket.sophos_url_linux

}

output "new_ssm_parameter" {
  value = module.ssm_operations.r7_token_name
}

output "named_instance_resource_group" {
  value = module.ssm_operations.all_named_ec2_rg
}

output "new_ssm_doc_windows" {
  value = module.ssm_operations.ssm_trio_doc_windows
}

output "new_ssm_doc_linux" {
  value = module.ssm_operations.ssm_trio_doc_linux
}

output "aws_ssm_maintenance_window_target" {
  value = module.ssm_operations.aws_ssm_maintenance_window_target_name
}
