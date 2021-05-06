provider_project     = ""
provider_region      = "us-east1"
cloudflare_email     = ""
cloudflare_api_key   = ""
# "CtqEsVdXtDEA6ryA6BgpPW4sqLEjKxGplwX9i3DA"
cloudflare_allowed_ip_address = ""

dns_zone_name = ""

# Whether to enable building triggers and Cloud Run services
# for production, staging and development git branches
enable_production = true
enable_staging = false
enable_development = false

postgres_db_name = "smd"
postgres_db_size = "db-custom-1-3840"
postgres_db_user = "smd"
postgres_db_pass = "p4ssw0rd"

function_bucket_name = "smd-cloudfunctions"

backup_bucket_name = "smd-backups-349"

computeinstance_name = "smd-docker"
#computeinstance_size = "e2-medium"
computeinstance_size = "e2-standard-4"
computeinstance_zone = "b"
computeinstance_disk_size = "100"
computeinstance_allowed_ports = ["8080", "8050","9000","1000","80","5555"]
