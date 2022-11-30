### AIZE Data Task:

This project is created for doing the analysis of data provided by 
aize for the data engineer task.

### Approach:

I approached this task by first creating a DAG to ingest data from the csv and xlsx files to a **PostGres** database, though **Apache Airflow**, to automate the ingestion process. Once data has been successfully imported to the  **PostGres** database instance then I began my analysis by writing SQL queries and visualizing them in Grafana, by creating various dashboard panels.


### Project Setup
To setup the project in your local machine please follow the below steps.

- Clone the project and move into the project directory.
- Run command `docker-compose up`. This command will start up 3 services
 - **airbnb_db**: Database server for managing internal **airflow** data, as will as **ingestion_data**. It has two separate databases,
   - **airflow**: For managing internal airflow data
   - **airbnb**: Used to store the results of ingestion.
   - **URL**: localhost:5436
 - **airflow_airbnb**: Airflow webserver
   - **URL**: http://localhost:8080
 - **grafana**: Grafana webserver
   - **URL**: http://localhost:3001

To see the dashboards you need to import the file  **reports/dashboard.json**, using the following instructions (https://grafana.com/docs/grafana/v9.0/dashboards/export-import/).


#### Ingest to Postgres DAG:

<img width="1698" alt="Screenshot 2022-11-30 at 03 45 11" src="https://user-images.githubusercontent.com/9046803/204703808-5cd9663b-8e98-4d8a-a1d2-7453193742a9.png">


