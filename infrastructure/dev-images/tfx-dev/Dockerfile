FROM gcr.io/deeplearning-platform-release/base-cpu
SHELL ["/bin/bash", "-c"]
RUN apt-get update -y && apt-get -y install kubectl
RUN conda create -n tfx python=3.6 && source activate tfx \
&& pip install -U httplib2==0.12.0 tensorflow==1.15 tensorflow-serving-api==1.15 \
&& pip install -U tfx==0.15.0rc0 \ 
&& RELEASE=0.1.32 \
&& pip install https://storage.googleapis.com/ml-pipeline/release/$RELEASE/kfp.tar.gz  \
&& python -m ipykernel install --name tfx 
RUN cd /usr/local/bin \
&& wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64 \
&& chmod 755 kustomize_3.1.0_linux_amd64 \
&& ln -s kustomize_3.1.0_linux_amd64 kustomize \
&& wget https://releases.hashicorp.com/terraform/0.12.8/terraform_0.12.8_linux_amd64.zip \
&& unzip terraform_0.12.8_linux_amd64.zip \
&& chmod 755 terraform