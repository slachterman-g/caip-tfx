# Development Environment deployment configurations.

This folder contains deployment configurations for a reference Development Environment.

To deploy the environment:
1. Provision infrastructure using **Terraform**
2. Deploy KFP pipelines using **Kustomize**

## Provisioning the environment's infrastructure
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

