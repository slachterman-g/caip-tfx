FROM gcr.io/deeplearning-platform-release/base-cpu
SHELL ["/bin/bash", "-c"]
RUN apt-get update -y && apt-get -y install kubectl google-cloud-sdk mysql-client
RUN PROTOC_ZIP=protoc-3.7.1-linux-x86_64.zip \
&& curl -OL https://github.com/google/protobuf/releases/download/v3.7.1/$PROTOC_ZIP \
&& unzip -o $PROTOC_ZIP -d /usr/local bin/protoc \
&& unzip -o $PROTOC_ZIP -d /usr/local include/* \
&& rm -f $PROTOC_ZIP
RUN conda create -n tfx python==3.6.8 && source activate tfx \
&& pip install tensorflow fire \
&& git clone https://github.com/tensorflow/tfx.git -b r0.14 \
&& cd tfx \
&& python setup.py sdist \
&& pip install dist/* \
&& RELEASE=0.1.29 \
&& pip install https://storage.googleapis.com/ml-pipeline/release/$RELEASE/kfp.tar.gz --upgrade \
&& python -m ipykernel install --name tfx
RUN cd /usr/local/bin \
&& wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64 \
&& chmod 755 kustomize_3.1.0_linux_amd64 \
&& ln -s kustomize_3.1.0_linux_amd64 kustomize \
&& wget https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip \
&& unzip terraform_0.12.8_linux_amd64.zip \
&& chmod 755 terraform