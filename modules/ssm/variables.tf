variable "ssm_doc_windows" {
  type    = string
  default = "Sophos-Rapid7-PatchManager_Windows"
}

variable "ssm_doc_linux" {
  type    = string
  default = "Sophos-Rapid7_Linux"
}

variable "ssm_param_name" {
  type    = string
  default = "r7-token"
}

variable "ssm_param_value" {
  type    = string
  default = "us:2cfd9fd3-d885-411f-8b0b-d7510da96bd8"
}

variable "ssm_sophos_url_windows" {
  type = string
}

variable "ssm_sophos_url_linux" {
  type = string
}

variable "ssm_rapid7_url_windows" {
  type = string
}

variable "ssm_rapid7_url_linux_x64_deb" {
  type = string
}

variable "ssm_pmp_url_windows" {
  type = string
}
variable "maintenance_win" {
  type    = string
  default = "Sophos-Rapid7-PatchManager"
}
