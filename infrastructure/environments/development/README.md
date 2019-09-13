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

In the reference configuration, KFP utilizes external MySQL instance and object storage. The KFP services are designed to read the connection settings (including credentials)  from a set of Kubernetes Secrets. 

*NOTE: In the current release of KFP, the connection settings are repeated in multiple secrets. The more consistent connection settings management will be introduced in future releases.*

The connection settings can be set before the KFP installation or as a part of the installation process. To minimize security exposure, it may be easier to configure them as a separate step before the installation. 

To configure connection settings:

1. Use Cloud Console or the `gcloud` command to create the `root` user in the MySQL instance. The instance created by the Terraform configuration has the root user removed.
1. Use Cloud Console or the `gcloud` command to create and download the JSON type private key for the KFP service user.
1. Create the Kubernetes namespace for the KFP services.
1. In the KFP namespace, create 
   - The `user-gcp-sa` secret to store the KFP service's private key. The content of the key file should be stored under the `applicaton_default_credentials.json` key.
   - The `mlpipelines-config` secret. The secret should have four keys: DB_USERNAME, DB_PASSWORD, DB_CONNECTION_NAME and, OBJECTSTORE_BUCKET_NAME. The format of DB_CONNECTION_NAME must be `project_id:region:mysql_instance_name`. The name of the GCS bucket for the object store must not include the `gs://` prefix.
   - The `mlmd-config` secret. The secret should have one key: `mlmd_config.prototxt`. The content of the key should be in the format demonstrated by the `kustomize\secrets_and_configs_templates\mlmd_config.prototxt` template.
 
### Installing Kubeflow Pipelines

To install KFP pipelines:
1. Make sure tha you have the latest version of `gcloud` and `kubectl` installed. Although, the latest versions of `kubectl` support **Kustomize** natively, it is recommended to install `kustomize` as a separate binary as it includes the latest updates that may have not yet made it to `kubectl`.
1. From the `kustomize` folder:
```
gcloud container get-credentials [YOUR_CLUSTER_NAME] --zone [YOUR_CLUSTER_ZONE]
kustomize build . | kubectl apply -f -
```

