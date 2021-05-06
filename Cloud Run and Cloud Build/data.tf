data "google_compute_instance" "docker" {
    name = var.ats_instance_name
    zone = var.ats_instance_zone
}