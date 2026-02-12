terraform {
  required_version = "~> 1.12"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.17.0"
    }
  }

  backend "s3" {
    bucket   = "chaldea-terraform-state"
    key      = "terraform.tfstate"
    region   = "eu-central-003"
    endpoint = "https://s3.eu-central-003.backblazeb2.com"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
