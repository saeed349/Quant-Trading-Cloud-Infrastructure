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
  version    = "~> 2.0"
  email      = var.cloudflare_email
  api_key    = var.cloudflare_api_key
}
data "google_project" "smd" {}