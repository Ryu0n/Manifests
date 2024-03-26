#! /bin/bash

if [ -f docker-compose.yaml ]; then
    echo "docker-compose.yaml is already exists."
else
    curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.8.0/docker-compose.yaml'
fi


mkdir -p ./dags ./logs ./plugins ./config
echo -e "AIRFLOW_UID=$(id -u)" > .env

docker compose up
