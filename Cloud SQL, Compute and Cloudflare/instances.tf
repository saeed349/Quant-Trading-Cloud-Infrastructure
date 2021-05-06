data "google_compute_network" "smd" {
  name = "default"
}

data "google_compute_subnetwork" "smd" {
  name          = "default"
  region        = var.provider_region
}

resource "google_compute_address" "smd-docker" {
  name  = "smd-docker"
}

resource "google_compute_instance" "smd-docker" {
  name         = var.computeinstance_name
  machine_type = var.computeinstance_size
  zone         = "${data.google_compute_subnetwork.smd.region}-${var.computeinstance_zone}"
  tags         = ["ssh-server", "smd-server"]

  boot_disk {
    initialize_params  {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size  = var.computeinstance_disk_size
    }
  }

  network_interface {
    subnetwork = "default"

    access_config {
      nat_ip = google_compute_address.smd-docker.address
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script   = "apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io && sudo curl -L \"https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose; mkdir -p /root/.ssh; echo \"${file("build.pem.pub")}\" >> /root/.ssh/authorized_keys; echo \"${file("build.pem")}\" >> /root/.ssh/id_rsa; chmod 600 /root/.ssh/id_rsa; echo \"Host *\" > /root/.ssh/config; echo \"  StrictHostKeyChecking no\" >> /root/.ssh/config"
  allow_stopping_for_update = true
}

output "instance_address" {
  value = google_compute_address.smd-docker.address
}
