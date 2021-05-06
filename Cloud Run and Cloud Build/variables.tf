variable "build_dockerfile_location" { 
    type    = string
    default = "."
}
variable "domain_name"               { type = map }
variable "enable_development"        { type = bool }
variable "enable_production"         { type = bool }
variable "enable_staging"            { type = bool }
variable "provider_credentials"      { type = string }
variable "provider_project"          { type = string }
variable "provider_region"           { type = string }
variable "repository_branch"         { type = map }
variable "repository_name"           { type = string }
variable "repository_owner"          { type = string }
variable "ats_repository_owner"      { type = string}
variable "ats_repository_name"       { type = string }
variable "ats_repository_branch"     { type = map }
variable "ats_repository_address"    { type = string }
variable "ats_instance_name"         { type = string }
variable "ats_instance_user"         { type = string }
variable "ats_instance_zone"         { type = string }

variable "cloudflare_email"          { type = string }
variable "cloudflare_api_key"        { type = string }
variable "cloudflare_allowed_ip_address" { type = string }
variable "dns_zone_name"             { type = string }
