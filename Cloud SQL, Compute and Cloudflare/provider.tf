provider "google-beta" {
  credentials = file(var.provider_credentials)
  project     = var.provider_project
  region      = var.provider_region
  version     = "~> 3.5"
}
provider "google" {
  credentials = file(var.provider_credentials)
  project     = var.provider_project
  region      = var.provider_region
  version     = "~> 3.5"
}
provider "cloudflare" {
  version    = "~> 2.9"
  email      = var.cloudflare_email
  api_token  = var.cloudflare_api_key
}
provider "random" {
  version = "~> 2.3"
}
data "google_project" "smd" {}