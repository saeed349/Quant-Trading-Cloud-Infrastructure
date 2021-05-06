provider_credentials = ""
provider_project     = ""
provider_region      = ""
cloudflare_email     = ""
cloudflare_api_key   = ""
cloudflare_allowed_ip_address = ""
dns_zone_name        = ""

# Domain name that will be mapped to the Cloud Run service.
# Leave blank for none.
domain_name = {
    production = ""
    staging = ""
    development = ""
}

# Whether to enable building triggers and Cloud Run services
# for production, staging and development git branches
enable_production = true
enable_staging = false
enable_development = false

# Where the Dockerfile is located, relative to the project's root. If it is in
# the project's root directory, use "." (default)
build_dockerfile_location = ""

repository_owner     = ""
repository_name      = ""
repository_branch = {
    production  = "master"
    staging     = "staging"
    development = "dev"
}
