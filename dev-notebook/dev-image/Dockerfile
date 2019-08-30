FROM gcr.io/deeplearning-platform-release/base-cpu
SHELL ["/bin/bash", "-c"]
RUN PROTOC_ZIP=protoc-3.7.1-linux-x86_64.zip \
&& curl -OL https://github.com/google/protobuf/releases/download/v3.7.1/$PROTOC_ZIP \
&& unzip -o $PROTOC_ZIP -d /usr/local bin/protoc \
&& unzip -o $PROTOC_ZIP -d /usr/local include/* \
&& rm -f $PROTOC_ZIP 
RUN conda create -n tfx python==3.7.3 && source activate tfx \
&& pip install tensorflow \
&& git clone https://github.com/tensorflow/tfx.git -b r0.14 \
&& cd tfx \
&& python setup.py sdist \
&& pip install dist/* \
&& python -m ipykernel install --name tfx


