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


import  fire
from pathlib import Path

def main(msg, output):
  import os
  
  print("Message: ", msg)
  print(os.environ)

  Path(output).parent.mkdir(parents=True, exist_ok=True)
  Path(output).write_text(msg)

if __name__ == "__main__":
  fire.Fire(main)