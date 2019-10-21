# CI/CD automation for TFX pipelines

This folder contains **Cloud Build** scripts to automate building and deploying of TFX pipelines:

- `tfx-cli` - this folder conatains a Dockerfile and a build script for a container with TFX CLI. This container is utilized by the `cloudbuild.yaml` automation script
- `cloudbuild.yaml` - **Cloud Build** configuration for automating compilation and deployment of TFX pipelines
- `build.sh` - the script demonstrating how to submit the CI/CD job


** Note. Make sure that the Cloud Build service account is granted the Kubernetes Engine Developer role**.

