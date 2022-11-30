FROM apache/airflow:2.4.2-python3.9
USER root

# RUN apt-get update && apt-get install -y gcc default-libmysqlclient-dev

EXPOSE 8080
EXPOSE 8793

RUN umask 0002; mkdir -p /workspaces
WORKDIR /workspaces

COPY requirements.txt .
RUN umask 0002; mkdir -p airflow/.airflow

USER airflow
RUN pip3 install -r requirements.txt

COPY . .

ENTRYPOINT ./airflow/init.sh
