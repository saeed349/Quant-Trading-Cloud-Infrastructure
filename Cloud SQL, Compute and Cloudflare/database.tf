resource "google_sql_database_instance" "smd-production" {
  name             = "smd-prod-${formatdate("YYYYMMDDhhmm",timestamp())}"
  region           = var.provider_region
  database_version = "POSTGRES_${var.postgres_version}"
  settings {
    tier = var.postgres_db_size
    ip_configuration {
      ipv4_enabled = "true"
      authorized_networks {
        name  = "internet"
        value = "0.0.0.0/0"
      }
    }
  }
  lifecycle {
    ignore_changes = [name]
  }
  provisioner "local-exec" {
    command = "bash scripts/database_set_acl.sh ${self.name} ${google_storage_bucket.smd-backup.name}"
  }
}

resource "random_string" "postgres_production_password" {
  length  = 64
  special = false
}

resource "google_sql_user" "smd-production" {
  name     = var.postgres_db_user
  instance = google_sql_database_instance.smd-production.name
  password = var.postgres_db_pass != "" ? var.postgres_db_pass : random_string.postgres_production_password.result 
  host     = ""
}


output "postgres_password" {
  value = google_sql_user.smd-production.password
}
output "postgres_username" {
  value = google_sql_user.smd-production.name
}
output "postgres_address" {
  value = google_sql_database_instance.smd-production.first_ip_address
}