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
- Copy the `env.tfvars` to the `bootstrap` directory

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

## Connect GCP to GitHub
Before creating the trigger the source repository **MUST** be connected
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
8. Choose the project by clicking on the checkbox besides it, the checkbox saying that you understand Google's terms and then clicking on "Connect Repository". 

**Skip the "Create a Push Triger" step.**

## Set up Cloud Build service account as a Cloud Run Admin
Grant the Cloud Run Admin role to the Cloud Build service account:

1. In Cloud Console, go to the Cloud Build Settings page.
2. Locate the row with the Cloud Run Admin role and set its Status to ENABLED.

If asked, choose "Grant Access to All Service Accounts"

## Map and verify your domain name ownership
1. Verify your domain in https://www.google.com/webmasters/verification/verification?domain=**foobar.com**  
Replace the domain name in **bold** with your real domain.
2. Navigate to this address in your web browser: https://www.google.com/webmasters/verification/home
3. Under **Properties**, click the domain for which you want to add a user or service account.
4. Scroll down to the Verified owners list, click Add an owner, and then enter the service account ID (or user) that owns the credentials terraform is using.

## Install terraform 0.12
The terraform templates were tested on terraform _v0.12.17_, _v0.12.18_, _v0.12.19_ and _v0.12.20_ (the latest at the time of the template creation). Please make
sure you're using a recent version of the **0.12 family**. **The templates will NOT work on terraform 0.11**.

Install Terraform by downloading it from the [official website](https://www.terraform.io/downloads.html), unzipping it and moving it to a directory included in your system's PATH .

Family upgrades (i.e: to an eventual _0.13_) may require rewrite and/or tweaking of the templates.

# Files
The following files are provided:

- **provider.tf**: Contains the authentication settings.
- **build.tf**: Contains the build trigger settings.
- **run.tf**: Contains the Cloud Run service deployment settings.
- **env.tfvars**: Contains the variables used on the other terraform files. The environment can be set up by tweaking these variables' values.

# Configuration Variables
The `env.tfvars` should be the only file you need to edit in order for things to work. The following variables are configurable:

- **provider_credentials**: Name of the file containing the credential's JSON file that terraform will use to authenticate with GCP.
- **provider_project**: ID of the GCP project that terraform will connect to.
- **provider_region**: Region where resources will be created.
- **domain_name**: Custom domain names that should be mapped to the Cloud Run services. Leave any values blank in order to map any domain name to a
particular environment. It will still be accessible through the automatically-generated URL (shown after terraform is run).
- **enable_production**, **enable_staging** and **enable_development**: Whether to enable building and deploying each of the branches. Setting one to false
will cause terraform not to create triggers and Cloud Run services to the specified branch. If you disable a branch, you **must** also leave its related
_domain_name_ setting blank.
- **build_dockerfile_location**: Where the `Dockerfile` file is located related to the repository root. Use `"."` if the file is in the root directory, 
otherwise use the full path to the file (don't use `/` in the beggining of the path).
- **repository_owner**: Name of the user owning the GitHub repository. If the URL to the repository is _https://github.com/user1/Dash-App_, then
the _repository_owner_ parameter should be set to **user1**.
- **repository_name**: Name of the GitHub repository. If the URL to the repository is _https://github.com/user1/Dash-App_, then
the repository_name parameter should be set to **Dash-App**.
- **repository_branch**: This is a mapping of the branch names to the environment's names. If your development branch is called "dev", for example, then it should be
set here.

# Initial Setup
1. Make sure you have completed setting up all the requisites
2. Review the **env.tfvars** files and make sure they match your app's settings
3. Apply the `bootstrap/bootstrap_build` build template to create the build pipelines
    - `cd bootstrap`
    - `terraform init`
    - `terraform apply -var-file env.tfvars`
4. Move the generated `bootstrap/terraform.tfstate` to the main directory
5. **(OPTIONAL)** remove the bootstrap directory. It won't be necessary again unless you're setting up a new project.
6. [Manually run](https://console.cloud.google.com/cloud-build/triggers) or commit to each of the branches to create the first image for each of the environments.

# General Usage
1. Make sure you've successfully finished all the steps in the [Initial Setup](# Initial Setup)
2. Initialize terraform inside the main directory
    - `terraform init`
3. Apply the templates
    - `terraform apply -var-file env.tfvars`
4. Make sure to safely store your `terraform.tfstate` file. This file should always be present in the main directory, and storing a backup after each apply is a good idea.

You won't generally need to run terraform after each commit. You can do these steps in case you need to reconfigure the environment or enable/disable features such as new branches. Subsequent applies will also make sure the deployment in the Cloud Run services are using the latest version of the container images, but the CI/CD process should routinely update them after repository pushes.

# DNS Setup
After creating the Cloud Run services you may also have chosen to create custom DNS mappings to those services. If so you'll need to add `CNAME` entries to your DNS
configuration pointing to **ghs.googlehosted.com.**

Each DNS provider has a slightly different process, but if you're using CloudFlare here is the way to do it:

1. Access your CloudFlare control panel
2. Select your domain
3. Click on _"DNS"_ on the top menu bar
4. Click on _"Add record"_
5. Click the _"Type"_ drop-down menu and select **CNAME**
6. Type in the name in the _"Name_" text box. If you want your service to be accessible on "www.mydomain.com", type "www"
7. Click on the orange cloud under _"Proxy status"_. It should turn gray. You can turn this back on later, after google verifies the domain.
8. Click on _"Save"_

# Solution Overview
## Build Pipelines
The build pipelines receive a notification from GitHub which trigger them. Then the application code is downloaded and a container is created based on the Dockerfile present on the repository. The container is stored in the Google Container Registry with two tags: the name of the environment (i.e: production, staging or development), which is the equivalent of the respective "latest" tag for each branch, and the build number so they can be referenced later. The last step is to update the Cloud Run deployment with the newly-built image.

On the first run the last step (updating the cloud run service) should not be run, so a "bootstrap" `bootstrap/bootstrap_build.tf` is provided without that last step to simplify the process.

## Cloud Run Services
The cloud run services are created using the environment's name tag and the build pipeline will update them with the specific build version. You might notice that re-running will change the deployment back to using the name tag, but since the name tag will always match the same image as the build number the deployment is using this is not an issue and will not affect the service in any way (this is a limitation of terraform, since it can't read the specific deployment tag that was most recently generated for an environment).

Every cloud run service also have a policy attached to it that will allow it to be accessed over the internet without the need to authenticate in google cloud platform and a domain mapping that allows custom domain names to be assigned to the running deployments.

# FAQ and error messages
**Q:** I received an error saying that the _"Repository mapping does not exist"_.  
**A:** You didn't connect your GCP account with your GitHub account or you didn't install Google Cloud Build on the repository you're setting up the build for.

**Q:** I got an error like _"Error: Error waiting to create Service: ContainerMissing - Image 'gcr.io/project_name/image:production' not found."_  
**A:** You're trying to create the Cloud Run service without an existing image. Review the [Initial Setup](# Initial Setup) section.
