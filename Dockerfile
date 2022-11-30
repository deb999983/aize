FROM apache/airflow:2.4.2-python3.9

# RUN apt-get update && apt-get install -y gcc default-libmysqlclient-dev

EXPOSE 8080
EXPOSE 8793

WORKDIR /workspaces

COPY requirements.txt .

RUN umask 0002; mkdir -p airflow/.airflow
RUN pip3 install -r requirements.txt

COPY . .

ENTRYPOINT ./airflow/init.sh
