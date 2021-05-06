provider "google-beta" {
  credentials = file(var.provider_credentials)
  project     = var.provider_project
  region      = var.provider_region
  version     = "~> 3.5"
}

# Before creating the trigger the source repository MUST be connected
# to your GCP project, otherwise you'll receive an error saying that
# the "Repository mapping does not exist". Please refer to the README
# file for more info.
resource "google_cloudbuild_trigger" "dash_analytics_production" {
  provider = google-beta
  count    = var.enable_production == true ? 1 : 0
  name     = "${lower(var.repository_name)}-production"

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
      args = ["build", "-t", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:production", var.build_dockerfile_location]
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
  }
}
resource "google_cloudbuild_trigger" "dash_analytics_staging" {
  provider = google-beta
  count    = var.enable_staging == true ? 1 : 0
  name     = "${lower(var.repository_name)}-staging"

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
      args = ["build", "-t", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:staging", var.build_dockerfile_location]
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
  }
}
resource "google_cloudbuild_trigger" "dash_analytics_development" {
  provider = google-beta
  count    = var.enable_development == true ? 1 : 0
  name     = "${lower(var.repository_name)}-development"

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
      args = ["build", "-t", "gcr.io/${var.provider_project}/${lower(var.repository_name)}:development", var.build_dockerfile_location]
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
  }
}