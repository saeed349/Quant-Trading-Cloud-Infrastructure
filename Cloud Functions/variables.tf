variable "backup_bucket_name"    { type = string }
variable "cloudflare_api_key"    { type = string }
variable "cloudflare_email"      { type = string }
variable "dns_zone_name"         { type = string }
variable "enable_development"    { type = bool }
variable "enable_production"     { type = bool }
variable "enable_staging"        { type = bool }
variable "function_bucket_name"  { type = string }
variable "computeinstance_name"  { type = string }
variable "computeinstance_size"  { type = string }
variable "computeinstance_zone"  { type = string }
variable "postgres_db_name"      { type = string }
variable "postgres_db_pass"      {
    type    = string
    default = ""
}
variable "postgres_db_size"      { type = string }
variable "postgres_db_user"      { type = string }
variable "postgres_version"      {
    type    = string
    default = "11"
}
variable "provider_credentials"  {
    type    = string
    default = "credentials.json"
}
variable "provider_project"      { type = string }
variable "provider_region"       { type = string }
variable "repository_branch"     { type = map }
variable "repository_name"       { type = map }
variable "repository_owner"      { type = map }
variable "repository_terraform_dir" {
    type    = map
    default = {}
}
variable "repository_default_terraform_dir" {
    type    = string
    default = "terraform"
}
variable "repository_app_dir"    {
    type    = map
    default = {}
}
variable "repository_default_app_dir" {
    type    = string
    default = "app"
}
