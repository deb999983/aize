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


### Some findings

#### Most Common Price Range
<img width="1263" alt="Screenshot 2022-11-30 at 04 43 55" src="https://user-images.githubusercontent.com/9046803/204703980-7f18a4d9-9241-44bd-83f3-0c6023f7aa79.png">

#### Most expensive neighbourhoods with their property counts
<img width="1273" alt="Screenshot 2022-11-30 at 04 57 21" src="https://user-images.githubusercontent.com/9046803/204704194-85d25254-610e-46f9-9e6d-0b6b42c56e5e.png">

#### Top neighbourhoods by PropertyCount, with Avg prices
<img width="1264" alt="Screenshot 2022-11-30 at 04 59 06" src="https://user-images.githubusercontent.com/9046803/204704457-1ae650a7-037e-4dee-aa18-faa2381a1cd7.png">

#### Expensive categories
<img width="1267" alt="Screenshot 2022-11-30 at 05 00 53" src="https://user-images.githubusercontent.com/9046803/204704594-c33c66a5-3ce0-4f9d-82d7-1fa4ba5be5e5.png">

#### Popular categories by sales
<img width="1262" alt="Screenshot 2022-11-30 at 05 01 33" src="https://user-images.githubusercontent.com/9046803/204704678-b034663c-f095-4e5b-ae8c-abc83c11f4e0.png">

#### Week on week sales to temp percentage comparision
<img width="1271" alt="Screenshot 2022-11-30 at 05 02 25" src="https://user-images.githubusercontent.com/9046803/204704784-0b73e37a-d19b-4440-ae6a-ed458eceadc3.png">

#### Sales vs Temp by week
<img width="1265" alt="Screenshot 2022-11-30 at 05 03 29" src="https://user-images.githubusercontent.com/9046803/204704901-2d68ce5e-c595-44d6-bd6f-dd5e9fa837fe.png">

#### Expensive neighbourhoods by property price
<img width="1264" alt="Screenshot 2022-11-30 at 05 11 55" src="https://user-images.githubusercontent.com/9046803/204705883-0df2ecc2-582b-484a-a0ea-fbdcba818bb4.png">

#### Neighbourhoods with max visits per property
<img width="1270" alt="Screenshot 2022-11-30 at 05 18 47" src="https://user-images.githubusercontent.com/9046803/204706549-2d4319e9-76d6-4488-b4a3-514ecc75ed5c.png">




