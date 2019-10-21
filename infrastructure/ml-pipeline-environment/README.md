# MLOPS Environment deployment configurations.

This folder contains deployment configurations for a reference MLOps Environment. The core services in the environment include:
- Experimentation and Development - AI Platform Notebooks
- Scalable Training - AI Platform Training
- Scalable Inference - AI Platform Prediction
- Scalable Data Preprocessing - Dataflow
- Orchestration - Kubeflow Pipelines (KFP)
- ML Metadata - Cloud SQL

![Reference topolgy](/images/environment.png)

In the reference environment, all services are configured in a single GCP projects. If you provision multiple environments (e.g. Development, Staging, and Production) each environment should utilize a dedictated project.

Currently, Kubeflow Pipelines is not available as a managed service. In the reference environment, the KFP services are deployed to a dedicated GKE cluster and configured to utilize:
- A Cloud SQL managed MySQL for ML Metadata and KFP Metadata databases
- A Cloud Storage bucket for object storage

The reference enviroment topology and configuration can be fine tuned for a specific role. For example Staging and Production environments optimized for a continuos training worfklow may not utilize AI Platform Notebooks or AI Platform Prediction services.

## Environment provisioning

The provisioning of an enviroment is a two step process
1. Provisioning the infrastructure for Kubeflow Pipelines 
1. Deploying Kubeflow Pipelines services 

The following GCP Cloud APIs  must be enabled in the project hosting the environment:
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
11. Cloud SQL Admin
12. Dataflow

In addition, the Cloud Build service account must be granted the Kubernetes Engine Developer role.

## Provisioning the Kubeflow Pipelines infrastructure

The MVP infrastructure to support a lightweight deployment of Kubeflow Pipelines comprises the following GCP services:
- A VPC to host GKE cluster
- A GKE cluster to host KFP services
- A Cloud SQL managed MySQL instance to host KFP and ML Metadata databases
- A Cloud Storage bucket to host artifact repository
- GKE and KFP service accounts with associated roles

If you want to utilize the existing services - e.g. the existing GKE cluster or existing Cloud SQL instance - make sure that they are configured as follows:
(TBD)

If you prefer to create a brand new infrastructure you can utilize the Terraform configuration provided in the `terraform` folder.

To use Terraform you need a workstation with the following components installed:
- Google Cloud SDK 
- Terraform
- Kustomize
- kubectl

All these components are pre-configured in the *tfx-dev* image. The following instructions assume that you utilize the *tfx-dev* image. If you prefer to use another client - for example Cloud Shell - make sure that you have installed the latest versions of **Google Cloud SDK**, **Kustomize**, and **kubectl**. 

If you use the *tfx-dev* image for the first time, make sure to initialize the access to your project with `gcloud init` and `gcloud auth application-default login` commands before proceeding with the below instructions.

To provision the infrastructure:

1. Update `terraform/backend.tf` to point to the GCS bucket and folder for Terraform state management. You can use a bucket in any project as long you have access to it.
2. Update `terraform/terraform.tfvars` with your *Project ID*, *Region*, and *Name Prefix*. The *Name Prefix* value will be added to the names of provisioned resources including: GKE cluster name, GCS bucket name, Cloud SQL instance name.
3. Execute the updated configuration from the `terraform` folder
```
cd terraform
terraform init
terraform apply
```

## Deploying Kubeflow Pipelines

The deployment of Kubeflow Pipelines to the environment's GKE cluster has been automated with **Kustomize**. 
Before applying the provided **Kustomize** overlays you need to configure connection settings to Cloud SQL and GCS. 

### Configuring connections settings to Cloud SQL and Cloud Storage

The KFP services access the Cloud SQL instance through Cloud SQL Proxy. To enable this access path, the Cloud SQL Proxy needs to be configured with a private key of the KFP service account and the KFP services need access to the credentials of a Cloud SQL database user. The private key and the credentials are stored as Kubernetes secrets. The URIs to the GCS bucket and the Cloud SQL instance are stored in a Kubernetes ConfigMap.

*Note: In the current release of KFP, the Cloud SQL instance needs to be configured with the root user with no password. The instance created by the Terraform configuration conforms to his constraint. This will be mitigated in the upcoming releases.*

To configure connection settings:
1. Use Cloud Console or the `gcloud` [command](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/keys/create)  to create and download a JSON type private key file for the KFP service user. If you provisioned the infrastructure with the provided Terraform configurations the user name is `[YOUR PREFIX]-kfp-cluster@[YOUR PROJECT ID].iam.gserviceaccount.com`. Rename the file to `application_default_credentials.json`. **Note that the `application_default_credentials.json` file contains sensitive information. Remeber to remove or secure the file after the installation process completes.**

2. Rename `gcp-configs.env.template` to `gcp-configs.env`. Replace the placeholders in the file with the values for your environment. Don't use the `gs://` prefix when configuring the *bucket_name*. If you provisioned the infrastructure with the provided Terraform configuration, the bucket name is `[YOUR_PREFIX]-artifact-store`. Use the following format for the *connection_name* - [YOUR PROJECT]:[YOUR REGION]:[YOUR INSTANCE NAME]. If you provisioned the infrastructure with the provided Terraform configuration the instance name is `[YOUR PREFIX]-ml-metadata`.

 
### Installing Kubeflow Pipelines

To install KFP pipelines:
1. Update the `kustomize/kustomization.yaml` with the name the namespace if you want to change the default name.
1. Apply the manifests. From the `kustomize` folder execute the following commands:
```
gcloud container clusters get-credentials  [YOUR CLUSTER NAME] --zone [YOUR ZONE]
kustomize build . | kubectl apply -f -
```

### Creating `user-gcp-sa` secret
Some pipelines - including TFX pipelines - use the pivate key stored in the `user-gcp-sa` secret to access GCP services. Use the same private key you used when configuring Cloud SQL Proxy.
```
kubectl create secret -n [your-namespace] generic user-gcp-sa --from-file=user-gcp-sa.json=application_default_credentials.json
```

## Accessing KFP UI

After the installation completes, you can access the KFP UI from the following URL. You may need to wait a few minutes before the URL is operational.

```
echo "https://"$(kubectl describe configmap inverse-proxy-config -n kubeflow | grep "googleusercontent.com")
```
