# MLOPS Environment deployment configurations.

This folder contains deployment configurations for a reference ML Environment. The core services in the environment include:
- Experimentation and Development - AI Platform Notebooks
- Scalable Training - AI Platform Training
- Scalable Inference - AI Platform Prediction
- Scalable Data Preprocessing - Dataflow
- Orchestration - Kubeflow Pipelines (KFP)
- ML Metadata - Cloud SQL

![Reference topolgy](/images/environment.png)

In the reference environment, AI Platform Notebooks are a primary workbench for experimentation and development. If you prefer to work in an IDE style environment the instructions for configuring Visual Studio Code for use with custom development container images can be found in the `dev-images` sections of this guide.

The reference enviroment topology and configuration can be fine tuned for a specific role. For example Staging and Production environments configured for Training may not utilize AI Platform Notebooks or AI Platform Prediction services.

## Provisioning an Environment
You can utilize the provided Infrastructure As Code (IaC) configurations and scripts to fine tune and provision an environment.
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

In the reference configuration, KFP utilizes external MySQL instance and object storage. The KFP services are designed to read the connection settings (including credentials)  from Kubernetes Secrets and ConfigMaps. 

To configure connection settings:

1. Navigate to the `kustomize` folder.
1. Use Cloud Console or the `gcloud` command to create the `root` user in the MySQL instance. The instance created by the Terraform configuration has the root user removed.
1. Use Cloud Console or the `gcloud` command to create and download the JSON type private key for the KFP service user. Rename the file to `application_default_credentials.json`
1. Rename `gcp-configs.env.template` and `mysql-credential.env.template` to `gcp-configs.env` and `mysql-credential.env`. Replace the placeholders in the files with your configs.
**Note that mysql-credential.env and application_default_credentials.json contain sensitive information. Remeber to remove or secure the files after the installation process completes.**
 
### Installing Kubeflow Pipelines

To install KFP pipelines:
1. Make sure that you have the latest version of `gcloud` and `kubectl` installed. Although, the latest versions of `kubectl` support **Kustomize** natively, it is recommended to install `kustomize` as a separate binary as it includes the latest updates that may have not yet made it to `kubectl`.
1. Update the `kustomize/kustomization.yaml` with the name the namespace if you want to change the default name.
1. Configure GKE credentials and apply the manifests:
```
gcloud container get-credentials [YOUR_CLUSTER_NAME] --zone [YOUR_CLUSTER_ZONE]
kustomize build kustomize | kubectl apply -f -
```

## Accessing KFP UI

After the installation completes, you can access the KFP UI from the following URL. You may need to wait a few minutes before the URL is operational.

```
echo "https://"$(kubectl describe configmap inverse-proxy-config -n kubeflow | grep "googleusercontent.com")
```
