# MLOPS Environment deployment configurations.

This folder contains deployment configurations for a reference ML Environment. The core services in the environment include:
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

## Provisioning an Environment

Provisioning of an environment has been organized as a three step process:
1. Enabling the required Cloud Services
1. Provisioning infrastructure for Kubeflow Pipelines 
1. Deploying Kubeflow Pipelines 

To execute the above steps you need a workstation with the following components installed:
- Google Cloud SDK 
- Kustomize
- kubectl

All the required components are pre-configured in the *tfx-dev* image. The following instructions assume that you utilize the *tfx-dev* image. If you prefer to use another client - for example Cloud Shell - make sure that you have installed the latest versions of **Google Cloud SDK**, **Kustomize**, and **kubectl**. 

If you use the *tfx-dev* image for the first time, make sure to initialize the access to your project with `gcloud init` and `gcloud auth application-default login` commands before proceeding with the below instructions.

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

In the reference configuration, KFP utilizes a Cloud SQL hosted MySQL instance as the ML Metadata database and a GCS storage bucket as the artifacts store. The KFP services access the Cloud SQL instance through Cloud SQL Proxy. To enable this access path, tCloud SQL Proxy needs to be configured with a private key of the KFP service account and the KFP services need access to the credentials of the root user of the Cloud SQL instance. The private key and the credentials are stored as Kubernetes secrets. In addtion, the URIs to the GCS bucket and the Cloud SQL instance are stored as a Kubernetes ConfigMap.

To configure connection settings:
1. Make sure that your Cloud SQL instance has the `root` user with a non-blank password.  The instance created by the provided Terraform configuration has the root user removed. Use Cloud Console or the `gcloud` command to create the `root` user in the MySQL instance.
1. Use Cloud Console or the `gcloud` [command](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/keys/create)  to create and download the JSON type private key for the KFP service user. If you provisioned the infrastructure with the provided Terraform configurations the user name is `[YOUR PREFIX]-kfp-cluster@[YOUR PROJECT ID].iam.gserviceaccount.com`. Rename the file to `application_default_credentials.json`. **Note that application_default_credentials.json contain sensitive information. Remeber to remove or secure the file after the installation process completes.**
1. Create a Kubernetes namespace. The default name is *kubeflow*. If you want to use a different name make sure to update the `kustomize.yaml` file as described in the following steps.
```
gcloud container clusters get-credentials [YOUR_CLUSTER_NAME] --zone [YOUR_CLUSTER_ZONE]
kubectl create namespace
```
1. Rename `gcp-configs.env.template` to `gcp-configs.env`. Replace the placeholders in the file with the values from your environment. Don't use the `gs://` prefix when configuring the *bucket_name*. If you provisioned the infrastructure with the provided Terraform configurations the bucket name is `[YOUR_PREFIX]-artifact-store`. Use the following format for the *connection_name* - [YOUR PROJECT]:[YOUR REGION]:[YOUR INSTANCE NAME]. If you provisioned the infrastructure with the provided Terraform configurations the instance name is `[YOUR PREFIX]-ml-metadata`.

 
### Installing Kubeflow Pipelines

To install KFP pipelines:
1. Make sure that you have the latest version of `gcloud` and `kubectl` installed. Although, the latest versions of `kubectl` support **Kustomize** natively, it is recommended to install `kustomize` as a separate binary as it includes the latest updates that may have not yet made it to `kubectl`. Follow [the installation procedure](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md) to install **Kustomize**. If you use the development container image, the tested version of **Kustomize** is pre-installed in the image.
1. Update the `kustomize/kustomization.yaml` with the name the namespace if you want to change the default name.
1. Configure GKE credentials and apply the manifests. From the `kustomize` folder execute the following commands:
```
gcloud container clusters get-credentials [YOUR_CLUSTER_NAME] --zone [YOUR_CLUSTER_ZONE]
kustomize build . | kubectl apply -f -
```

## Accessing KFP UI

After the installation completes, you can access the KFP UI from the following URL. You may need to wait a few minutes before the URL is operational.

```
echo "https://"$(kubectl describe configmap inverse-proxy-config -n kubeflow | grep "googleusercontent.com")
```
