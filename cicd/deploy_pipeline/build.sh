#!/bin/bash
# Copyright 2019 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#            http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Submits a Cloud Build job that builds and deploys
# the pipelines and pipelines components 

SUBSTITUTIONS=\
_PIPELINE_FOLDER=chicago_taxi,\
_PIPELINE_DSL=taxi_pipeline_kfp.py,\
_TFX_CUSTOM_IMAGE=tfx_demo,\
_TAG=latest,\
_CLUSTER_NAME=tfx-dev6-kfp-cluster,\
_ZONE=us-central1-a
#_KFP_ENDPOINT=7c42fe4d130f0063-dot-datalab-vm-us-west1.googleusercontent.com

gcloud builds submit ../../pipelines --config cloudbuild.yaml --substitutions $SUBSTITUTIONS

