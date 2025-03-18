provider "aws" {
  region  = basename(path.cwd)
  profile = var.profile
}

module "create_s3_bucket" {
  source                  = "../modules/s3"
  source_sophos_windows   = var.path_sophos_windows
  source_sophos_linux     = var.path_sophos_linux
  source_r7_windows       = var.path_r7_windows
  source_r7_deb_linux_x64 = var.path_r7_deb_linux_x64
  source_pmp_windows      = var.path_pmp_windows
  source_pmp_linux        = var.path_pmp_linux
  r7_linux_version        = var.r7_linux_version

}

module "ssm_operations" {
  source                       = "../modules/ssm"
  ssm_sophos_url_windows       = module.create_s3_bucket.sophos_url_windows
  ssm_rapid7_url_windows       = module.create_s3_bucket.rapid7_url_windows
  ssm_pmp_url_windows          = module.create_s3_bucket.pmp_url_windows
  ssm_rapid7_url_linux_x64_deb = module.create_s3_bucket.rapid7_url_linux_x64_deb
  ssm_sophos_url_linux         = module.create_s3_bucket.sophos_url_linux

}
