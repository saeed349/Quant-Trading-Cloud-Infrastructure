# Solution Overview
This project creates the environment for running the `APLICATION_NAME_PLACEHOLDER` app. It is comprised of *(at least)*  2 parts:
- smd (this repository)
- cloud function repository

Multiple cloud function repositories may exist. Adding new functions is possible and the process of doing that is described on the `howto/ADD_NEW_FUNCTIONS.md` file.

## smd
This repository is responsible for creating the underlying infrastructure necessary for running the apps, but does not contain the apps themselves. The following infrastructure components are created and managed here, through its own `.tf` file:
- Postgresql databases: `database.tf`
- Google Cloud Storage buckets: `buckets.tf`
- Google Cloud Build triggers: `build_[FUNCTION_NAME].tf`
- Google Compute instances: `compute.tf`

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
- **database.tf**: Contains the Cloud SQL definitions. By default databases are publicly accessible. This is so that functions can access the databases, since Google does not provide fixed ip addresses for them.
- **instances.tf**: Contains the Compute Instance definitions.
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
- **postgres_db_name**: Name of the postgres instance and databases. This will actually be used
as a prefix for the actual values.
- **postgres_db_size**: Size (type) of the Postgresql server instance.
- **postgres_db_user**: Name of the user used to access the databases. Note that the user will be
able to access all the databases in the instance.
- **postgres_db_pass**: Password of the user used to access the databases. Defaults to a random password if empty or unset.
- **postgres_version**: Sets the version of the Postgresql database servers. Defaults to `11` if unset. Valid values are `11` or `9_6`.
- **function_bucket_name**: Name of the Google Storage bucket used to store Cloud Function-related objects. This is also used by terraform to store the function state files and for locking during builds.
- **backup_bucket_name**: Name fo the Google Storage bucket used to store database backups whenever a database is destroyed. These backups are automatically reloaded into newly-created databases.
- **repository_owner**: Map containing the users owning the GitHub Cloud Function repositories. If the URL to the repository is _https://github.com/saeed349/Dash-Analytics-App_, then
the _repository_owner_ parameter should be set to **saeed349**.
- **repository_name**: Map containing the names of the GitHub Cloud Function repositories. If the URL to the repository is _https://github.com/saeed349/Dash-Analytics-App_, then
the repository_name parameter should be set to **Dash-Analytics-App**.
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

# Scripts
Shell scripts for database provisioning and backup are provided in the `scripts` directory. These scripts are:
- `database_backup.sh`: Creates backups of existing databases and store them on a Google Cloud Storage bucket. Runs when a database is destroyed.
- `database_restore.sh`: Restores existing backups from a Google Cloud Storage bucket into existing databases. Runs when a database is created.
- `database_set_acl.sh`: Sets the ACLs on Google Cloud Storage buckets in order to allow the backups to be saved in the bucket. This is mostly an auxiliary script, and runs when a database instance is created.

# Other notes
## Destroying environments
When destroying environments the Google Cloud Storage buckets will not be removed and you'll receive an error about that. **This is expected** and is done to prevent accidental data loss on the buckets.

Data that might be essential are the state files in the functions bucket and the database backups on the backups bucket. In order to remove the buckets please delete all files manually from them. You can access your buckets on the [GCP console](https://console.cloud.google.com/storage/browser).

If you really want to remove the buckets automatically you can add the `force_destroy = true` parameters to the buckets on the `buckets.tf` file and apply the environment settings. Please note that deleting the buckets is an irreversible operation, so use this with care.

## Removing Cloud Functions
No triggers are provided to remove created cloud functions. In order to do so please remove them on the [GCP console](https://console.cloud.google.com/functions). After doing that should also remove the related state files from the cloud functions bucket.