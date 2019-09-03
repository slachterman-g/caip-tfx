This folder contains a deployment configuration for a custom, container based AI Platform Notebook optimized for TFX and Kubeflow Pipelines development.
The notebook's container image is a derivative of the `base-cpu` Deep Learning container (`gcr.io/deeplearning-platform-release/base-cpu`) and includes the following addtional components:
- Python 3.6.8
- Tensorflow 1.14
- TFX 0.14
- The latest version of KFP SDK 
- Fire 
The above packages are pre-installed in a conda environment named `tfx`. This environment is linked into a Jupyter kernel also named `tfx`.

