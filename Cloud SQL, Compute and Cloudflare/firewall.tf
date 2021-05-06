resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = data.google_compute_network.smd.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}
resource "google_compute_firewall" "allow-docker-ports" {
  name    = "allow-docker-ports"
  network = data.google_compute_network.smd.name

  allow {
    protocol = "tcp"
    ports    = var.computeinstance_allowed_ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["smd-server"]
}
