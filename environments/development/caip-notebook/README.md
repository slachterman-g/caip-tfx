# AI Platform Notebook for TFX/KFP development

This folder contains a deployment configuration for a custom, container based AI Platform Notebook optimized for TFX and Kubeflow Pipelines development.

The custom container image is a derivative of the `base-cpu` Deep Learning container (`gcr.io/deeplearning-platform-release/base-cpu`) and includes the following additional components:
- Python 3.6.8
- Tensorflow 1.14
- TFX 0.14
- The latest version of KFP SDK 
- Python Fire 
- kubectl
- mysql client

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

## Using the TFX/KFP development image with Visual Studio Code
You can also use the image with your favorite IDE. The following instructions demonstrate how to configure Visual Studio Code for remote development using an AI Platform Notebook. The instructions were tested on MacOS but should be transferable to other platforms.

1. Make sure you can connect to the AI Platform Notebook's vm instance from your workstation using `ssh`
```
gcloud compute ssh [YOUR AI PLATFORM NOTEBOOK VM NAME] --zone [YOUR ZONE]
```
2. Create a configuration for the VM in your `~/.ssh/config`
```
Host [YOUR CONFIGURATION NAME]
  User [YOUR USER NAME]
  HostName [YOUR VM'S IP ADDRESS]
  IdentityFile /Users/[YOUR USER NAME]/.ssh/google_compute_engine
```
3. Test the configuration
```
ssh [YOUR CONFIGURATION NAME]
```

4. Install Docker (On a Mac install Docker Desktop for Mac)

https://docs.docker.com/docker-for-mac/install/

5. Install Visual Studio Code

https://code.visualstudio.com/download

6. Install Visual Studio Code Remote Development Extension

https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack

7. You can now connect to AI Platform Notebook using a SSH tunnel. 
  - Update the `docker.host` property in your user or workspace `settings.json` as follows
  ```
  "docker.host":"tcp//localhost:23750"
  ```
  - From a local terminal set up an SSH tunnel
  ```
  ssh -NL localhost:23570:/var/run/docker.sock [YOUR CONFIGURATION NAME] 
  ```


8. In Visual Studio Code bring up the **Command Palette** (F1) and type in Remote-Containers for a full list of commands. Choose **Attach to Running Container** and select your ssh configuration.


