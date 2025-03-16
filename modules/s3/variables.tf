variable "source_sophos_windows" {
  type    = string
  default = "D:\\temp\\sophos.exe"
}

variable "source_sophos_linux" {
  type    = string
  default = "D:\\temp\\sophos.sh"
}

variable "source_r7_windows" {
  type    = string
  default = "D:\\temp\\agentInstaller-x86_64.msi"
}

variable "source_r7_deb_linux_x64" {
  type    = string
  default = "D:\\temp\\rapid7_x64.deb"
}

variable "r7_linux_version" {
  type    = string
  default = "4.0.12.14"
}

variable "source_pmp_windows" {
  type    = string
  default = "D:\\temp\\pmp.zip"
}

variable "source_pmp_linux" {
  type    = string
  default = "D:\\temp\\pmp_linux.zip"
}
