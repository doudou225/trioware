variable "profile" {
  type = string
}

variable "path_sophos_windows" {
  type = string
}

variable "path_sophos_linux" {
  type = string
}

variable "path_r7_windows" {
  type = string
}

variable "path_r7_deb_linux_x64" {
  type = string
}

variable "r7_linux_version" {
  type = string
  
  validation {
    condition = can(regex("^[0-9]+(\\.[0-9]+)*$", var.r7_linux_version))
    error_message = "Rapid7 version consists only of digits and dots!"
  }
}

variable "path_pmp_windows" {
  type = string
}

variable "path_pmp_linux" {
  type = string
}
