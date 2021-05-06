resource "google_storage_bucket" "smd-backup" {
  name     = var.backup_bucket_name
  location = var.provider_region

  versioning {
    enabled = true
  }
}
resource "google_storage_bucket" "smd" {
  name          = var.function_bucket_name
  versioning {
    enabled = true
  }
}
resource "google_storage_bucket_access_control" "cloudbuild" {
  bucket = google_storage_bucket.smd.name
  role   = "WRITER"
  entity = "user-${data.google_project.smd.number}@cloudbuild.gserviceaccount.com"
}
