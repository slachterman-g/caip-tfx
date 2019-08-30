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

# Create an AI Platform Notebook based on a custom image


if [[ $# < 3 ]]; then
  echo "Error: Arguments missing. [INSTANCE_NAME INSTANCE_ZONE IMAGE_URI]"
  exit 1
fi

export INSTANCE_NAME=${1}
export IMAGE_URI=${3}
export IMAGE_FAMILY="common-container" 
export ZONE=${2}
export INSTANCE_TYPE="n1-standard-8"


gcloud compute instances create $INSTANCE_NAME \
        --zone=$ZONE \
        --image-family=$IMAGE_FAMILY \
        --image-project="deeplearning-platform-release" \
        --maintenance-policy=TERMINATE \
        --machine-type=$INSTANCE_TYPE \
        --boot-disk-size=100GB \
        --scopes=https://www.googleapis.com/auth/cloud-platform \
        --metadata="proxy-mode=project_editors,container=$IMAGE_URI"