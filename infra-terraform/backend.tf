#
#===============================================================================
# Backend
#===============================================================================
#

terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "nexus/eu-west/prod"
    region = "us-east-1"
    endpoint = "https://us-east-1.linodeobjects.com"
    skip_credentials_validation = true
    encrypt = false
  }
}
