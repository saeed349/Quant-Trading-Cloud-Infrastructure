provider_project     = ""
provider_region      = ""
cloudflare_email     = ""
cloudflare_api_key   = ""

dns_zone_name = "domain_name"

# Whether to enable building triggers and Cloud Run services
# for production, staging and development git branches
enable_production = true
enable_staging = false
enable_development = false


function_bucket_name = "smd-cloudfunctions"

backup_bucket_name = "smd-backups"

repository_owner = {
  sample_cloud_function_1 = "user1"
}
repository_name = {
  sample_cloud_function_1 = "repo1"
}
repository_branch = {
    sample_cloud_function_1 = {
        production  = "master"
        staging     = "staging"
        development = "dev"        
    }
}
