# AI Platform Notebook for TFX/KFP development

This folder contains a deployment configuration for a custom, container based AI Platform Notebook optimized for TFX and Kubeflow Pipelines development.

The custom container image is a derivative of the `base-cpu` Deep Learning container (`gcr.io/deeplearning-platform-release/base-cpu`) and includes the following additional components:
- Python 3.6.8
- Tensorflow 1.14
- TFX 0.14
- The latest version of KFP SDK 
- Python Fire 
- kubectl

The Python packages are pre-installed in a conda environment named `tfx`. This environment is linked into a Jupyter kernel also named `tfx`.

Since the image is a derivative of a Deep Learning container it can be used to provision an AI Platform Notebook.

## Creating an AI Platform Notebook 
To create an AI Platform Notebook based on the image:
1. Build the image using the Dockerfile in the `dev-image` folder and push it into your project's **Container Registry**. The `build.sh` script demonstrates how to build and push the image using **Cloud Build**
2. Use the `create-notebook.sh` script to provision an AI Platform Notebook. After a few minutes the notebook will appear in the AI Platform Notebooks section of GCP Console. You can retrieve the URL to JupyterLab using the following `gcloud` command:
```
INSTANCE_NAME=[YOUR NOTEBOOK NAME]
gcloud compute instances describe "${INSTANCE_NAME}" \
  --format='value[](metadata.items.proxy-url)' 
```

## Using the TFX/KFP development image with IDE
You can also use the image with your favorite IDE. The following instructions demonstrate how to configure Visual Studio Code for remote development using an AI Platform Notebook.


