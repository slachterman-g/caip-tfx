# Development Environment deployment configurations.

This folder contains deployment configurations for a reference Development Environment.

To deploy the environment:
1. Provision infrastructure using **Terraform**
1. Create database users and service account credentials
2. Deploy KFP pipelines using **Kustomize**

## Provisioning the environment's infrastructure

The MVP infrastructure to support a lightweight deployment of Kubeflow Pipelines can be created using the Terraform configuration in the `terraform` folder. The configuration provisions the following services:
- A GKE cluster to host KFP services
- A Cloud SQL managed MySQL instance to host KFP and ML Metadata databases
- A Cloud Storage bucket to host artifact repository
- GKE and KFP service accounts with associated roles

The Terraform configuration utilizes the module from
https://github.com/jarokaz/terraform-gcp-kfp.
Refer to the module's documentation for more information.

To provision infrastructure:

1. Update `terraform/backend.tf` to point to the GCS bucket for Terraform state management
2. Update `terraform/terraform.tfvars` with your *Project ID*, *Region*, and *Name Prefix*. 
3. Execute the updated configuration
```
cd terraform
terraform init
terraform apply
```

## Creating database users and service account credentials
For security reasons the Terraform configuration did not create any MySQL users or service account credentials. In this step, you create the required database users and service account credentials.

**IMPORTANT**. In the below steps you will **temporarily** store the credentials in a set of text files for the use by **Kustomize**. Make sure to protect the files and delete them immediately after the KFP install is completed.

To create the required users and credentials 
1. Rename the `kustomize\secrets_and_configs_templates` folder to `kustomize\secrets_and_configs` 
1. Using Cloud Console or the `gcloud` command create the MySQL `'root'@'%'` user. Do not use an empty password.
1. Update `cloudsql_config.txt` with the MySQL connection name and the root user's password.
1. Update `mlmd_config.prototxt` with the root user's password
1. Using Cloud Console or the `gcloud` command create and download the JSON type private key for the KFP service account.
1. Rename the JSON key file to `application_default_credentials.json` and move it to the `secrets_and_configs` folder.



## Deploying KFP pipelines



To deploy KFP pipelines:

