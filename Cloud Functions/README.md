
# Solution Overview
This project creates the environment for running the [Google Cloud Functions](https://cloud.google.com/functions) service .

Multiple cloud function repositories may exist. Adding new functions is possible and the process of doing that is described at the end of this markdown. 


## Cloud Function repository
Any number of cloud functions may be deployed. Each function is basically a flask app and should be hosted in its own github project and have the following structure:
-`/app`: This directory contains the application (function) that will run. Any number of files may be present and will be deployed, but at least a `main.py` **must** be present. Usually a `requirements.txt` (containing any module dependencies) should be present as well.
- `/terraform`: This directory contains the terraform definitions of the function and is used by the build process. This is responsible for uploading the application to the Google Cloud Storage bucket and creating/updating the related cloud function.

Configuration is done through the `env.tfvars` file.

# Requisites
## Terraform project Setup
### Linux
- Unpack the .tar.gz file
- Make sure you have terraform **v0.12.17** or newer installed
- Edit the `env.tfvars` file as required

### Windows
- Unpack the .zip file
- Make sure you have terraform **v0.12.17** or newer installed
- Edit the `env.tfvars` file as required

## GCP Credentials for Terraform
Terraform needs permissions to create and modify all Cloud Run, Cloud Build and Container Registry-related resources. The easiest way
to do this is to create a service account with project owner permissions.

**Note**: KEEP THE CREDENTIALS FILE SECURE. Access to it could compromise all your Google Cloud account. There is a `.gitignore` file
supplied with this that'll prevent commiting files named `credentials.json` to prevent accidental submitting this to a git repository.

To create the credentials file:

1. Open your [GCP Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) page
2. Click on _"Create service account"_
3. Fill in a name (such as terraform) and a description for the account and click _"create"_
4. Choose _"Project -> Owner"_ and click _"Continue"_
5. Click on _"Create Key"_, choose _"JSON"_ and click on _"Create"_. Move the downloaded file to the terraform directory and rename it to `credentials.json`  
If you're on Windows you also need to place a copy of this file in the `bootstrap` directory.
6. Click _"Done"_

## Install gcloud
You need the [gcloud sdk](https://cloud.google.com/sdk) installed and set up with your account in order for the database backup and restore operations to work.

To install it, follow the instructions on https://cloud.google.com/sdk/docs/downloads-interactive

After installing:
- Open a command line terminal
- Type `gcloud auth login`
- Follow the instructions and complete the login procedure
- Type `gcloud config set project PROJECT_ID`, replacing *PROJECT_NAME* for your actual GCP project ID

## Install terraform 0.12
The terraform templates were tested on terraform _v0.12.17_, _v0.12.18_, _v0.12.19_ and _v0.12.20_ (the latest at the time of the template creation). Please make
sure you're using a recent version of the **0.12 family**. **The templates will NOT work on terraform 0.11**.

Install Terraform by downloading it from the [official website](https://www.terraform.io/downloads.html), unzipping it and moving it to a directory included in your system's PATH .

Family upgrades (i.e: to an eventual _0.13_) may require rewrite and/or tweaking of the templates.

**Note** When using terraform `v0.12.18` or newer, you'll receive a deprecation warning. As of terraform `v0.12.20` this can be safely ignored.

## Set up Cloud Build service account as a Cloud Functions Developer
Grant the Cloud Functions Admin role to the Cloud Build service account. This needs to be done only once in a new GCP project:

1. In Cloud Console, go to the project [IAM settings](https://console.cloud.google.com/iam-admin/iam)
2. Locate the Cloud Build account. It will be named like `project_id@cloudbuild.gserviceaccount.com`
3. Click the edit (pencil) button
4. On the side panel, click on *ADD ANOTHER ROLE*
5. Click on *Select a role*
6. Type `cloud functions admin` on the *Type to filter* box
7. Click on the filter result
8. Click on *SAVE*

## Connect GCP to GitHub
Before creating the trigger the Cloud Function source repositories *MUST* be connected
to your GCP project.

Follow the steps below to properly set up your GCP connecting with GitHub.

### Connecting GCP to GitHub
1. Open your [GCP panel](https://console.cloud.google.com)
2. Search for _"Cloud Build"_
3. Click on _"Triggers"_
4. Click on _"Connect Repository"_
5. Choose _"GitHub (Cloud Build GitHub App)"_
6. Follow the authentication steps on the screen. 
7. Click on _"Install Google Cloud Build"_. You can then install it on all repositories or only on the project you want to build on GCP. 
8. Choose the project by clicking on the checkbox besides it, the checkbox saying that you understand Google's terms and then clicking on "Connect Repository". **Make sure to select all the projects related to the Cloud Functions you want to deploy.**

**Skip the "Create a Push Triger" step.**

# Files
The following files are provided:

- **env.tfvars**: Contains the variables used on the other terraform files. The environment can be set up by tweaking these variables' values. This is the only file that should require manual adjustments.
- **build_[CLOUD_FUNCTION_NAME].tf**: Contains the build trigger definitions. One must be present for each Cloud Function that is deployed.
- **buckets.tf**: Contains the Cloud Storage Bucket definitions.
- **permissions.tf**: Contains ACL definitions.
- **provider.tf**: Contains the authentication definitions.

# Environment Setup
## Configuration Variables
The `env.tfvars` should be the only file you need to edit in order for things to work. The following variables are configurable:

- **provider_project**: ID of the GCP project that terraform will connect to.
- **provider_region**: Region where resources will be created.
- **provider_credentials**: Name of the file containing the credential's JSON file that terraform will use to authenticate with GCP. Defaults to `credentials.json` if unset (recommended).
- **enable_production**, **enable_staging** and **enable_development**: Whether to enable building and deploying each of the branches. Setting one to false
will cause terraform not to create triggers and Cloud Run services to the specified branch.
- **function_bucket_name**: Name of the Google Storage bucket used to store Cloud Function-related objects. This is also used by terraform to store the function state files and for locking during builds.
- **backup_bucket_name**: Name fo the Google Storage bucket used to store database backups whenever a database is destroyed. These backups are automatically reloaded into newly-created databases.
- **repository_owner**: Map containing the users owning the GitHub Cloud Function repositories.
- **repository_name**: Map containing the names of the GitHub Cloud Function repositories.
- **repository_branch**: This is a mapping of the branch names to the environment's names. If your development branch is called "dev", for example, then it should be
set here.
- **repository_app_dir**: Map containing the Cloud Function application directory. Defaults to `app` if unset (recommended).
- **repository_terraform_dir**: Map containing the Clouf Function terraform directory. Defaults to `terraform` if unset (recommended).

## Applying configurations
- Make sure you have followed **all** the procedures on the Requirements section of this document.
- Make sure the `env.tfvars` is properly set
- Initialize terraform inside the main directory. This is only needed on the first run.  
`terraform init`
- Apply the environment settings:  
`terraform apply -var-file env.tfvars`
- Make sure to safely store your `terraform.tfstate` file. This file should always be present in the main directory, and storing a backup after each apply is a good idea.
- Load the database schemas into the server. This is only necessary on the first run, as backups will be created and loaded automatically from the backup bucket on subsequent runs (provided the buckets and/or backup files are not manually removed)


# Other notes
## Destroying environments
When destroying environments the Google Cloud Storage buckets will not be removed and you'll receive an error about that. **This is expected** and is done to prevent accidental data loss on the buckets.

Data that might be essential are the state files in the functions bucket and the database backups on the backups bucket. In order to remove the buckets please delete all files manually from them. You can access your buckets on the [GCP console](https://console.cloud.google.com/storage/browser).

If you really want to remove the buckets automatically you can add the `force_destroy = true` parameters to the buckets on the `buckets.tf` file and apply the environment settings. Please note that deleting the buckets is an irreversible operation, so use this with care.

## Removing Cloud Functions
No triggers are provided to remove created cloud functions. In order to do so please remove them on the [GCP console](https://console.cloud.google.com/functions). After doing that should also remove the related state files from the cloud functions bucket.


# Adding new Cloud Functions
- Create a file named `build_[repository_name].tf` file. Replace *[repository_name]* with the actual function name.
- Paste the following contents into the file you just created, **replacing all occurrences of repository_name with the actual function's repository name**:
```
resource "google_cloudbuild_trigger" "repository_name" {
  provider = google-beta
  count = var.enable_production == true ? 1 : 0
  name  = "${lower(replace(lookup(var.repository_name, "repository_name"), "_", "-"))}-production"

  github {
    owner = lookup(var.repository_owner, "repository_name")
    name  = lookup(var.repository_name, "repository_name")
    push {
      branch = lookup(var.repository_branch["repository_name"], "production")
    }
  }

  build {
    step {
      name       = "kramos/alpine-zip"
      entrypoint = "zip"
      dir        = lookup(var.repository_app_dir, "repository_name", var.repository_default_app_dir)
      args       = [ "-r", "function.zip", "." ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)
      args       = [ "-i", "s/ENV/${lookup(var.repository_name, "repository_name")}/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "sed"
      dir        = lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)
      args       = [ "-i", "s/PREFIX/$BRANCH_NAME/g", "provider.tf" ]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      dir        = lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)
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
        "mv ${lookup(var.repository_app_dir, "repository_name", var.repository_default_app_dir)}/function.zip ${lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)}/function.zip"
      ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)
      args = [ "init" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)
      args = [ "plan", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
    step {
      name = "hashicorp/terraform"
      dir  = lookup(var.repository_terraform_dir, "repository_name", var.repository_default_terraform_dir)
      args = [ "apply", "-auto-approve", "-var-file=$BRANCH_NAME.tfvars", "-var", "provider_project_name=$PROJECT_ID" ]
    }
  }
}
```
- Edit the `env.tfvars` file and add the new function's repository info to the required variables:
    - repository_owner
    - repository_name
    - repository_branch
- Apply the environment settings:  
`terraform apply -var-file=env.tfvars`
- Make a commit in the remote function's repository in order to trigger the new build.