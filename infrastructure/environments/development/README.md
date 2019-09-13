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


## Deploying KFP pipelines

For security reasons the Cloud SQL instance was created without databases users and the private keys were not created for the service accounts.

To deploy KFP pipelines:
1. Create the `root` user in the CloudSQL instance created in the previous step. 
2. Create and d
