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

# Build a custome AI Platform Notebook image using Cloud Build

if [[ $# < 3 ]]; then
  echo "Error: Arguments missing. [build PROJECT_ID REPO_NAME IMAGE_TAG]"
  exit 1
fi

IMAGE_URI="gcr.io/${1}/${2}:${3}"

gcloud builds submit --tag ${IMAGE_URI} .
