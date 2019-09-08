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
import kfp
from kfp import gcp


# Define a test component
STAGING_DIR = "gs://caip-demo-staging/tmp"
BASE_IMAGE = "google/cloud-sdk:latest"
TARGET_IMAGE = 'gcr.io/jk-demo1/test-component:latest'

def print_env(msg: str) -> str:
  import os
  
  print("Message: ", msg)
  print(os.environ)

  return msg


test_op = kfp.compiler.build_python_component(
  component_func=print_env,
  staging_gcs_path=STAGING_DIR,
  base_image=BASE_IMAGE,
  target_image=TARGET_IMAGE
)

# Pipeline definition
@kfp.dsl.pipeline(
    name='Test pipeline',
    description='Test pipeline'
)
def test_pipeline(
  message="Hello"
):
  """Trains and optionally deploys a CLV Model."""

  # Load sales transactions
  test_task = test_op(message)

  # Configure the pipeline to use a service account secret
  if True:
    steps = [
        test_task
    ]
    for step in steps:
      step.apply(gcp.use_gcp_secret('user-gcp-sa'))

# Compile the pipelinea
pipeline_filename = test_pipeline.__name__ + '.tar.gz'
kfp.compiler.Compiler().compile(test_pipeline, pipeline_filename)
kfp.Client().create_run_from_pipeline_package(pipeline_filename, {})