This folder contains a Dockerfile template for a custom image for Kubeflow Jupyter Notebooks. 
The template builds and image as a derviative of the AI Platform Notebook image and
sets the entrypoint as required by Kubeflow Jupyter Notebooks. Make sure to modify **FROM** command to point your base image.