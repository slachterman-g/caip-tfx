FROM python:3.6-slim-jessie
RUN apt-get update && apt-get install git curl unzip -y
RUN PROTOC_ZIP=protoc-3.7.1-linux-x86_64.zip \
&& curl -OL https://github.com/google/protobuf/releases/download/v3.7.1/$PROTOC_ZIP \
&& unzip -o $PROTOC_ZIP -d /usr/local bin/protoc \
&& unzip -o $PROTOC_ZIP -d /usr/local include/* \
&& rm -f $PROTOC_ZIP
RUN pip install tensorflow==1.14 httplib2==0.12.0 \
&& git clone https://github.com/tensorflow/tfx.git \
&& cd tfx \
&& python setup.py sdist \
&& pip install dist/*  \
&& cd \
&& git clone https://github.com/kubeflow/pipelines.git \
&& cd pipelines/sdk/python \
&& ./build.sh \
&& pip install kfp.tar.gz 
# Install gcloud SDK
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN mkdir -p /usr/local/gcloud
RUN tar -C /usr/local/gcloud -xf /tmp/google-cloud-sdk.tar.gz
RUN /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

ENTRYPOINT ["/bin/bash"]
