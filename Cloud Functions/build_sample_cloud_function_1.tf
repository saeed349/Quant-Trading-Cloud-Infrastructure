# Before creating the trigger the source repository MUST be connected
# to your GCP project, otherwise you'll receive an error saying that
# the "Repository mapping does not exist". Please refer to the README
# file for more info.
resource "google_cloudbuild_trigger" "sample_cloud_function_1-production" {
  provider = google-beta
  count = var.enable_production == true ? 1 : 0
  name  = "${lower(replace(lookup(var.repository_name, "sample_cloud_function_1"), "_", "-"))}-production"

  github {
    owner = lookup(var.repository_owner, "sample_cloud_function_1")
    name  = lookup(var.repository_name, "sample_cloud_function_1")
    push {
      branch = lookup(var.repository_branch["sample_cloud_function_1"], "production")
    }
  }

  build {
    step {
      name       = "kramos/alpine-zip"
      entrypoint = "zip"
      dir        = lookup(var.repository_app_dir, "sample_cloud_function_1", var.repository_default_app_dir)
      args       = [ "-r", "function.zip", "." ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args       = [ "-i", "s/ENV/${lookup(var.repository_name, "sample_cloud_function_1")}/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args       = [ "-i", "s/PREFIX/$BRANCH_NAME/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ 
        "-c",
        "BUCKET=$(grep function_bucket_name $BRANCH_NAME.tfvars|cut -f2 -d\\\"); sed -i \"s/BUCKET/$$BUCKET/g\" provider.tf"
      ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [ 
        "-c",
        "mv ${lookup(var.repository_app_dir, "sample_cloud_function_1", var.repository_default_app_dir)}/function.zip ${lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)}/function.zip"
      ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "init" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "plan", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "apply", "-auto-approve", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
  }
}
resource "google_cloudbuild_trigger" "sample_cloud_function_1-staging" {
  provider = google-beta
  count = var.enable_staging == true ? 1 : 0
  name  = "${lower(replace(lookup(var.repository_name, "sample_cloud_function_1"), "_", "-"))}-staging"

  github {
    owner = lookup(var.repository_owner, "sample_cloud_function_1")
    name  = lookup(var.repository_name, "sample_cloud_function_1")
    push {
      branch = lookup(var.repository_branch["sample_cloud_function_1"], "staging")
    }
  }

  build {
    step {
      name       = "kramos/alpine-zip"
      entrypoint = "zip"
      dir        = lookup(var.repository_app_dir, "sample_cloud_function_1", var.repository_default_app_dir)
      args       = [ "-r", "function.zip", "." ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args       = [ "-i", "s/ENV/${lookup(var.repository_name, "sample_cloud_function_1")}/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args       = [ "-i", "s/PREFIX/$BRANCH_NAME/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ 
        "-c",
        "BUCKET=$(grep function_bucket_name $BRANCH_NAME.tfvars|cut -f2 -d\\\"); sed -i \"s/BUCKET/$$BUCKET/g\" provider.tf"
      ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [ 
        "-c",
        "mv ${lookup(var.repository_app_dir, "sample_cloud_function_1", var.repository_default_app_dir)}/function.zip ${lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)}/function.zip"
      ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "init" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "plan", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "apply", "-auto-approve", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
  }
}
resource "google_cloudbuild_trigger" "sample_cloud_function_1-development" {
  provider = google-beta
  count = var.enable_development == true ? 1 : 0
  name  = "${lower(replace(lookup(var.repository_name, "sample_cloud_function_1"), "_", "-"))}-development"

  github {
    owner = lookup(var.repository_owner, "sample_cloud_function_1")
    name  = lookup(var.repository_name, "sample_cloud_function_1")
    push {
      branch = lookup(var.repository_branch["sample_cloud_function_1"], "development")
    }
  }

  build {
    step {
      name       = "kramos/alpine-zip"
      entrypoint = "zip"
      dir        = lookup(var.repository_app_dir, "sample_cloud_function_1", var.repository_default_app_dir)
      args       = [ "-r", "function.zip", "." ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args       = [ "-i", "s/ENV/${lookup(var.repository_name, "sample_cloud_function_1")}/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args       = [ "-i", "s/PREFIX/$BRANCH_NAME/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      dir        = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ 
        "-c",
        "BUCKET=$(grep function_bucket_name $BRANCH_NAME.tfvars|cut -f2 -d\\\"); sed -i \"s/BUCKET/$$BUCKET/g\" provider.tf"
      ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [ 
        "-c",
        "mv ${lookup(var.repository_app_dir, "sample_cloud_function_1", var.repository_default_app_dir)}/function.zip ${lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)}/function.zip"
      ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "init" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "plan", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "sample_cloud_function_1", var.repository_default_terraform_dir)
      args = [ "apply", "-auto-approve", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
  }
}