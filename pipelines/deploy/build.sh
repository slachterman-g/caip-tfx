#!/bin/bash
#
# Submits a Cloud Build job that builds and deploys
# the pipelines and pipelines components 

SUBSTITUTIONS=\
_PIPELINE_FOLDER=chicago_taxi,\
_PIPELINE_DSL=taxi_pipeline_kfp.py,\
_TFX_CUSTOM_IMAGE=tfx_demo,\
_TAG=latest,\
_CLUSTER_NAME=tfx-dev2-kfp-cluster,\
_ZONE=us-central1-a
#_KFP_ENDPOINT=7c42fe4d130f0063-dot-datalab-vm-us-west1.googleusercontent.com

gcloud builds submit ../ --config cloudbuild.yaml --substitutions $SUBSTITUTIONS

