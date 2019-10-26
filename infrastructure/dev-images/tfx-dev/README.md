# AI Platform Notebook for TFX/KFP development

This folder contains the Dockerfile and the build script for the AI Platform Notebook container image optimized for TFX and Kubeflow Pipelines development.

The  image is a derivative of the `base-cpu` Deep Learning container (`gcr.io/deeplearning-platform-release/base-cpu`) and includes the following additional components:
- Python 3.6
- Tensorflow 1.15
- TFX - 0.15.0rc0
- KFP SDK - 1.32
- Python Fire 
- kubectl
- mysql client
- Kustomize 3.1.0
- Terraform 0.12.8

The Python packages are pre-installed in a conda environment named `tfx`. This environment is linked into a Jupyter kernel also named `tfx`.

Since the image is a derivative of a Deep Learning container it can be used to provision an AI Platform Notebook.

## Creating an AI Platform Notebook 
To create an AI Platform Notebook based on the image:
1. Build the image and push it into your project's **Container Registry**. The `build.sh` script demonstrates how to build and push the image using **Cloud Build**
2. Create a CPU based AI Platform Notebook using [Cloud Console](https://console.cloud.google.com/ai-platform/notebooks/instances). When configuring the notebook's host VM,  use the **Customize instance** option and select **Custom container** in the **Environment** drop list. Enter the full URI to the custom image created in the previous step.

## Using the TFX/KFP development image with Visual Studio Code
You can also use the image with Visual Studio Code for both local and remote development.  The following instructions were tested on MacOS but should be transferable to other platforms.

### Preparing your MacOS workstation
1. Install and initialize [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart-macos)

1. [Install Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/)

1. [Install Visual Studio Code](https://code.visualstudio.com/download)

1. [Install Visual Studio Code Remote Development Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)


### Configuring Visual Studio Code for local development
1. Clone this repo on your workstation
2. In the repo's root create the `.devcontainer` folder.
3. In the `.devcontainer` folder create a Dockerfile:
```
FROM gcr.io/[YOUR PROJECT ID]/tfx-dev-3.6
```
4. In the `.devcontainer` folder create the `devcontainer.json` file. Refer to https://github.com/microsoft/vscode-dev-containers/tree/master/containers/docker-existing-dockerfile for more information about the configuration options. The below configuration tells VSC to create an image using the provided Dockerfile and install Microsoft Python extension after the container is started.
```
{
	"name": "Existing Dockerfile",
	"context": "..",
	"dockerFile": "Dockerfile",
	"settings": { 
		"terminal.integrated.shell.linux": null
	},
	"extensions": ["ms-python.python"]
}
```
5. From the Visual Studio Code command pallete (**[SHIFT][COMMAND][P]**) select **Remote-Containers:Open Folder in Container**. Find the root folder of the repo. After selecting the folder, Visual Studio Code downloads your image, starts the container and installs the Python extension to the container. 

### Configuring Visual Studio Code for remote development
1. Create an AI Platform Notebook using the development image as described in the **Creating an AI Platform Notebook** section.
2. Make sure you can connect to the AI Platform Notebook's vm instance from your workstation using `ssh`
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
4. You can now connect to AI Platform Notebook using a SSH tunnel. 
  - Update the `docker.host` property in your user or workspace Visual Studio Code `settings.json` as follows
  ```
  "docker.host":"tcp//localhost:23750"
  ```
  - From a local terminal set up an SSH tunnel
  ```
  ssh -NL localhost:23750:/var/run/docker.sock [YOUR CONFIGURATION NAME] 
  ```

5. In Visual Studio Code bring up the **Command Palette** (**[SHIFT][COMMAND][P]**)) and type in **Remote-Containers** for a full list of commands. Choose **Attach to Running Container** and select your ssh configuration.


