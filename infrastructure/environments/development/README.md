# Development Environment deployment configurations.

This folder contains deployment configurations for a reference Development Environment. The core services in the environment include:
- AI Platform Notebooks
- AI Platform Training
- AI Platform Prediction
- Kubeflow Pipelines (KFP)

Currently, Kubeflow Pipelines is not available as a managed service. In the reference environment, the KFP services are deployed to a dedicated GKE cluster and configured to utilize:
- A Cloud SQL managed MySQL for ML Metadata and KFP Metadata databases
- A Cloud Storage bucket for object storage

To configure the environment:
1. Enable the required Cloud Services
1. Provision infrastructure for Kubeflow Pipelines
1. Deploy KFP pipelines 

## Provisioning the Kubeflow Pipelines infrastructure

The MVP infrastructure to support a lightweight deployment of Kubeflow Pipelines can be created using the Terraform configuration in the `terraform` folder. The configuration provisions the following services:
- A VPC to host GKE cluster
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

### Configuring connections settings to Cloud SQL and Cloud Storage

In the reference configuration, KFP utilizes external MySQL instance and object storage. The KFP services are designed to read the connection settings (including credentials) to these cloud resources from a set of Kubernetes Secrets and Config Maps. 

*NOTE: In the current release of KFP, the connection settings are repeated in multiple secrets and maps. The more consistent connection settings management will be introduced in future releases.*

The connection settings can be set before the KFP installation or as a part of the installation process. To minimize security exposure, it may be easier to configure them as a separate step before the installation. If you prefer to fully automate the installation process, including configuration of secrets you can utilize **Kustomize** secret and config map generators as demonstrated in the `kustomization_generators.yaml` template.

To configure connections settings before the installation:

1. Use Cloud Console or the `gcloud` command to configure the `root` user in the MySQL instance. The instance created by the Terraform configuration has a root user removed.
1. Use Cloud Console or the `gcloud` command to create and download the JSON type private key for the KFP service user.
1. Create the Kubernetes namespace for the KFP services.
1. In the KFP namespace, create 
  - The `user-gcp-sa` secret to store the KFP service's private key. The JSON key file should be stored under the `applicaton_default_credentials.json` key.
  - The `cloudsql-config` secret. The secret should have three keys: DB_USERNAME, DB_PASSWORD, CONNECTION_NAME. The format of CONNECTION_NAME must be `project_id:region:mysql_instance_name`
  
1. 

