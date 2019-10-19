# MLOPS Environment deployment configurations.

This folder contains deployment configurations for a reference ML Environment. The core services in the environment include:
- Experimentation and Development - AI Platform Notebooks
- Scalable Training - AI Platform Training
- Scalable Inference - AI Platform Prediction
- Scalable Data Preprocessing - Dataflow
- Orchestration - Kubeflow Pipelines (KFP)
- ML Metadata - Cloud SQL

![Reference topolgy](/images/environment.png)

The reference enviroment topology and configuration can be fine tuned for a specific role. For example Staging and Production environments optimized for a continuos training worfklow may not utilize AI Platform Notebooks or AI Platform Prediction services.

## Provisioning an Environment
In the reference environment, all services are configured in a single GCP projects. If you provision multiple environments (e.g. Development, Staging, and Production) each environment should utilize a dedictated project.

Currently, Kubeflow Pipelines is not available as a managed service. In the reference environment, the KFP services are deployed to a dedicated GKE cluster and configured to utilize:
- A Cloud SQL managed MySQL for ML Metadata and KFP Metadata databases
- A Cloud Storage bucket for object storage

Provisioning of an environment has been organized as a three step process:
1. Enabling the required Cloud Services
1. Provisioning infrastructure for Kubeflow Pipelines and configuring service accounts and permissions
1. Deploying KFP pipelines 

## Enabling Cloud Services
The following GCP Cloud APIs need to be enabled in the project hosting an environment:
1. Compute Engine
2. Cloud Storage
3. Container Registry
4. Kubernetes Engine
5. BigQuery
6. Cloud Build
7. Cloud Resource Manager
8. Cloud Machine Learning Engine
9. IAM
10. Cloud SQL
11. Dataflow


## Provisioning the Kubeflow Pipelines infrastructure

The MVP infrastructure to support a lightweight deployment of Kubeflow Pipelines comprises the following GCP services:
- A VPC to host GKE cluster
- A GKE cluster to host KFP services
- A Cloud SQL managed MySQL instance to host KFP and ML Metadata databases
- A Cloud Storage bucket to host artifact repository
- GKE and KFP service accounts with associated roles

If you want to utilize the existing services - e.g. the existing GKE cluster or existing Cloud SQL instance - make sure that they are configured as follows:
(TBD)

You can provision all services required to host Kubeflow Pipelines using the provided Terraform configurations. The configurations utilize the modules from
https://github.com/jarokaz/terraform-gcp-kfp.
Refer to the module's documentation for more information.

To provision the infrastructure:

1. Update `terraform/backend.tf` to point to the GCS bucket and folder for Terraform state management. You can use the bucket in any project as long you have access to it.
2. Update `terraform/terraform.tfvars` with your *Project ID*, *Region*, and *Name Prefix*. The *Name Prefix* will be added to the name of provisioned resources including: GKE cluster name, GCS bucket name, Cloud SQL instance name.
3. Execute the updated configuration from the `terraform` folder
```
cd terraform
terraform init
terraform apply
```
You can execute the above commands from any workstation configured with Google Cloud SDK and Terraform, including Cloud Shell and the custom dev image.

## Deploying KFP pipelines

The deployment of Kubeflow Pipelines to the environment's GKE cluster has been automated with **Kustomize**. Before running the provided **Kustomize** overlays you need to configure connections settings to Cloud SQL and GCS store. 

### Configuring connections settings to Cloud SQL and Cloud Storage

In the reference configuration, KFP utilizes external MySQL instance and object storage. The KFP services are designed to read the connection settings (including credentials)  from Kubernetes Secrets and ConfigMaps. 

To configure connection settings:
1. Make sure that your Cloud SQL instance has the `root` user with a non-blank password.  The instance created by the provided Terraform configuration has the root user removed. Use Cloud Console or the `gcloud` command to create the `root` user in the MySQL instance.
1. Navigate to the `kustomize` folder.
1. Use Cloud Console or the `gcloud` [command](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/keys/create)  to create and download the JSON type private key for the KFP service user that was created by Terraform. Unless you modified the Terraform configurations the user name will be `[YOUR PREFIX]-kfp-cluster@[YOUR PROJECT ID].iam.gserviceaccount.com`. Rename the file to `application_default_credentials.json`
1. Rename `gcp-configs.env.template` and `mysql-credential.env.template` to `gcp-configs.env` and `mysql-credential.env`. Replace the placeholders in the files with your values.
**Note that mysql-credential.env and application_default_credentials.json contain sensitive information. Remeber to remove or secure the files after the installation process completes.**
 
### Installing Kubeflow Pipelines

To install KFP pipelines:
1. Make sure that you have the latest version of `gcloud` and `kubectl` installed. Although, the latest versions of `kubectl` support **Kustomize** natively, it is recommended to install `kustomize` as a separate binary as it includes the latest updates that may have not yet made it to `kubectl`. Follow [the installation procedure](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md) to install **Kustomize**. If you use the development container image, the tested version of **Kustomize** is pre-installed in the image.
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
