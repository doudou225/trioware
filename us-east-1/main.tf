provider "aws" {
  region  = basename(path.cwd)
  profile = var.profile
}

module "create_s3_bucket" {
  source = "../modules/s3"

}

module "ssm_operations" {
  source                       = "../modules/ssm"
  ssm_sophos_url_windows       = module.create_s3_bucket.sophos_url_windows
  ssm_rapid7_url_windows       = module.create_s3_bucket.rapid7_url_windows
  ssm_pmp_url_windows          = module.create_s3_bucket.pmp_url_windows
  ssm_rapid7_url_linux_x64_deb = module.create_s3_bucket.rapid7_url_linux_x64_deb
  ssm_sophos_url_linux         = module.create_s3_bucket.sophos_url_linux

}
