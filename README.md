### AIZE Data Task:

This project is created for doing the analysis of data provided by 
aize for the data engineer task.

### Approach:

I approached this task by first creating a DAG to ingest data from the csv and xlsx files to a **PostGres** database, though **Apache Airflow**. Once data has been successfully imported to the  **PostGres** database instance then I began my analysis by writing SQL queries and visualizing them in Grafana, by creating various dashboard panels.


#### Ingest to Postgres DAG:



