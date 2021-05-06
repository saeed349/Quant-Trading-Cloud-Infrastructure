  data "google_container_registry_image" "dash_analytics_production" {
  count = var.enable_production == true ? 1 : 0
  name  = lower(var.repository_name)
  tag   = "production"
}
data "google_container_registry_image" "dash_analytics_staging" {
  count = var.enable_staging == true ? 1 : 0
  name  = lower(var.repository_name)
  tag   = "staging"
}
data "google_container_registry_image" "dash_analytics_development" {
  count = var.enable_development == true ? 1 : 0
  name  = lower(var.repository_name)
  tag   = "development"
}

resource "google_cloud_run_service" "dash_analytics_production" {
  count    = var.enable_production == true ? 1 : 0
  name     = "${lower(var.repository_name)}-production"
  location = var.provider_region
  template {
    spec {
      containers {
        image = data.google_container_registry_image.dash_analytics_production[0].image_url
      }
    }
  }
  traffic {
    percent = 100
    latest_revision = true
  }
  timeouts {
    create = "15m"
  }
  lifecycle{
    ignore_changes = ["template[0].spec[0].containers[0].image"]
  }
}
resource "google_cloud_run_service" "dash_analytics_staging" {
  count    = var.enable_staging == true ? 1 : 0
  name     = "${lower(var.repository_name)}-staging"
  location = var.provider_region
  template {
    spec {
      containers {
        image = data.google_container_registry_image.dash_analytics_staging[0].image_url
      }
    }
  }
  traffic {
    percent = 100
    latest_revision = true
  }
  timeouts {
    create = "15m"
  }
}
resource "google_cloud_run_service" "dash_analytics_development" {
  count    = var.enable_development == true ? 1 : 0
  name     = "${lower(var.repository_name)}-development"
  location = var.provider_region
  template {
    spec {
      containers {
        image = data.google_container_registry_image.dash_analytics_development[0].image_url
      }
    }
  }
  traffic {
    percent = 100
    latest_revision = true
  }
  timeouts {
    create = "15m"
  }
}

resource "google_cloud_run_domain_mapping" "dash_analytics_production" {
  count    = lookup(var.domain_name, "production") != "" ? 1 : 0
  name     = lookup(var.domain_name, "production")
  location = google_cloud_run_service.dash_analytics_production[0].location
  
  metadata {
    namespace = var.provider_project
  }

  spec {
    route_name = google_cloud_run_service.dash_analytics_production[0].name
  }
}
resource "google_cloud_run_domain_mapping" "dash_analytics_staging" {
  count    = lookup(var.domain_name, "staging") != "" ? 1 : 0
  name     = lookup(var.domain_name, "staging")
  location = google_cloud_run_service.dash_analytics_staging[0].location
  
  metadata {
    namespace = var.provider_project
  }

  spec {
    route_name = google_cloud_run_service.dash_analytics_staging[0].name
  }
}
resource "google_cloud_run_domain_mapping" "dash_analytics_development" {
  count    = lookup(var.domain_name, "development") != "" ? 1 : 0
  name     = lookup(var.domain_name, "development")
  location = google_cloud_run_service.dash_analytics_development[0].location
  
  metadata {
    namespace = var.provider_project
  }

  spec {
    route_name = google_cloud_run_service.dash_analytics_development[0].name
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "dash_analytics_production_noauth" {
  count       = var.enable_production == true ? 1 : 0
  location    = google_cloud_run_service.dash_analytics_production[0].location
  project     = google_cloud_run_service.dash_analytics_production[0].project
  service     = google_cloud_run_service.dash_analytics_production[0].name

  policy_data = data.google_iam_policy.noauth.policy_data
}
resource "google_cloud_run_service_iam_policy" "dash_analytics_staging_noauth" {
  count       = var.enable_staging == true ? 1 : 0
  location    = google_cloud_run_service.dash_analytics_staging[0].location
  project     = google_cloud_run_service.dash_analytics_staging[0].project
  service     = google_cloud_run_service.dash_analytics_staging[0].name

  policy_data = data.google_iam_policy.noauth.policy_data
}
resource "google_cloud_run_service_iam_policy" "dash_analytics_development_noauth" {
  count       = var.enable_development == true ? 1 : 0
  location    = google_cloud_run_service.dash_analytics_development[0].location
  project     = google_cloud_run_service.dash_analytics_development[0].project
  service     = google_cloud_run_service.dash_analytics_development[0].name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "cloud_run_production_url" {
  value = join("", google_cloud_run_service.dash_analytics_production[*].status.0.url)
}
output "cloud_run_staging_url" {
  value = join("", google_cloud_run_service.dash_analytics_staging[*].status.0.url)
}
output "cloud_run_development_url" {
  value = join("", google_cloud_run_service.dash_analytics_development[*].status.0.url)
}
