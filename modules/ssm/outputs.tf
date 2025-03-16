output "r7_token_name" {
  value = aws_ssm_parameter.rapid7_token.name
}

output "ssm_trio_doc_windows" {
  value = aws_ssm_document.trio_windows.name
}

output "ssm_trio_doc_linux" {
  value = aws_ssm_document.duo_linux.name
}

output "all_named_ec2_rg" {
  value = aws_resourcegroups_group.all_named_instances_rg.name
}

output "aws_ssm_maintenance_window_name" {
  value = aws_ssm_maintenance_window.trio-maintenance-Window.name
}

output "aws_ssm_maintenance_window_target_name" {
  value = aws_ssm_maintenance_window_target.trio-target.name
}
