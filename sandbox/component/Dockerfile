FROM python:3.6-slim-jessie

RUN pip install  google-cloud-storage google-cloud-automl grpcio fire

RUN mkdir /ml

WORKDIR /ml

COPY main.py /ml

ENTRYPOINT ["python", "main.py"]
