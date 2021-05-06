# Before creating the trigger the source repository MUST be connected
# to your GCP project, otherwise you'll receive an error saying that
# the "Repository mapping does not exist". Please refer to the README
# file for more info.
resource "google_cloudbuild_trigger" "dash_analytics_production" {
  provider = google-beta
  count = var.enable_production == true ? 1 : 0
  name  = "${lower(var.repository_name)}-production"

  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch = lookup(var.repository_branch, "production")
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:production", "dash-docker"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["tag", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:production", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:production"]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", "${lower(var.repository_name)}-production", "--image", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID", "--region", "${var.provider_region}", "--platform", "managed", "--allow-unauthenticated"]
    }
  }
}
resource "google_cloudbuild_trigger" "dash_analytics_staging" {
  provider = google-beta
  count = var.enable_staging == true ? 1 : 0
  name  = "${lower(var.repository_name)}-staging"

  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch = lookup(var.repository_branch, "staging")
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:staging", "dash-docker"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["tag", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:staging", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:staging"]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", "${lower(var.repository_name)}-staging", "--image", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID", "--region", "${var.provider_region}", "--platform", "managed", "--allow-unauthenticated"]
    }
  }
}
resource "google_cloudbuild_trigger" "dash_analytics_development" {
  provider = google-beta
  count = var.enable_development == true ? 1 : 0
  name  = "${lower(var.repository_name)}-development"

  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch = lookup(var.repository_branch, "development")
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:development", "dash-docker"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["tag", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:development", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:development"]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", "${lower(var.repository_name)}-development", "--image", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:$BUILD_ID", "--region", "${var.provider_region}", "--platform", "managed", "--allow-unauthenticated"]
    }
  }
}
resource "google_cloudbuild_trigger" "Algorithmic_Trading_System-production" {
  provider = google-beta
  count = var.enable_production == true ? 1 : 0
  name  = "${lower(var.ats_repository_name)}-production"

  github {
    owner = var.ats_repository_owner
    name  = var.ats_repository_name
    push {
      branch = lookup(var.ats_repository_branch, "production")
    }
  }

  build {
    timeout = "3600s"
    step {
      name = "ubuntu"
      args = ["bash", "./deploy-to-instance.sh", data.google_compute_instance.docker.network_interface.0.access_config.0.nat_ip, "root", var.ats_repository_address]
    }
  }
}
