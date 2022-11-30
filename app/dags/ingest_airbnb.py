import fileinput

from datetime import datetime
from airflow import DAG
from airflow.utils.task_group import TaskGroup

from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator


def ingest_data(sql, file_name, **kwargs):
    postgres_hook = PostgresHook(postgres_conn_id="aize_db")
    postgres_hook.copy_expert(sql=sql, filename=f'app/Case/{file_name}')


def normalize_csv_headers(file_name, **kwargs):
    for line in fileinput.input(f'app/Case/{file_name}', inplace=True):
        if fileinput.isfirstline():
            headers = line.split(',')
            headers = map(lambda header: header.replace(" ", '_').lower(), headers)
            print(','.join(headers), end='')
        else:
            print(line, end='')


with DAG(
    'ingest_to_postgres', 
    description='Hello World DAG',
    schedule_interval=None,
    start_date=datetime(2017, 3, 20), catchup=False
) as ddag:

    start = EmptyOperator(task_id='start')

    with TaskGroup(group_id="normalize_headers") as normalize_headers:
        normalize_property_headers = PythonOperator(task_id='normalize_property_headers', python_callable=normalize_csv_headers, op_args=['Property_sales_data_New_York.csv',])
        normalize_weather_headers = PythonOperator(task_id='normalize_weather_headers', python_callable=normalize_csv_headers, op_args=['Weather Data.csv',])
        normalize_airbnb_headers = PythonOperator(task_id='normalize_airbnb_headers', python_callable=normalize_csv_headers, op_args=['Airbnb_data_New_York.csv',])

    with TaskGroup(group_id="airbnb") as airbnb:
        create_airbnb_table = PostgresOperator(task_id='create_airbnb_table', postgres_conn_id='aize_db', sql="""
            DROP TABLE IF EXISTS public.airbnb_data_ny;
            CREATE TABLE IF NOT EXISTS public.airbnb_data_ny (
                id integer NULL,
                "name" varchar(255) NULL,
                host_id integer NULL,
                host_name varchar(255) NULL,
                neighbourhood_group varchar(255) NULL,
                neighbourhood varchar(255) NULL,
                latitude real NULL,
                longitude real NULL,
                room_type varchar(255) NULL,
                price integer NULL,
                minimum_nights integer NULL,
                number_of_reviews integer NULL,
                last_review date NULL,
                reviews_per_month real NULL,
                calculated_host_listings_count integer NULL,
                availability_365 integer NULL
            );    
        """
        )
        truncate_airbnb_table = PostgresOperator(task_id="truncate_airbnb_table", postgres_conn_id='aize_db', sql="""
            TRUNCATE TABLE public.airbnb_data_ny;
        """)
        ingest_airbnb_data = PythonOperator(task_id='ingest_airbnb_data', python_callable=ingest_data, op_args=[
            """ 
            COPY public.airbnb_data_ny FROM STDIN WITH (FORMAT CSV, DELIMITER ',',  HEADER true)
            """,
            "Airbnb_data_New_York.csv"
        ])

        create_airbnb_table >> truncate_airbnb_table >> ingest_airbnb_data

    with TaskGroup(group_id="property_sales") as property_sales:
        create_property_sales_table = PostgresOperator(task_id='create_property_sales_table', postgres_conn_id='aize_db', sql="""
            DROP TABLE IF EXISTS public.property_sales_ny;
            CREATE TABLE public.property_sales_ny (
                column1 integer NULL,
                borough integer NULL,
                neighborhood varchar(255) NULL,
                building_class_category varchar(255) NULL,
                tax_class_at_present varchar(255) NULL,
                block integer NULL,
                lot integer NULL,
                "ease-ment" varchar(255) NULL,
                building_class_at_present varchar(255) NULL,
                address varchar(255) NULL,
                apartment_number varchar(255) NULL,
                zip_code integer NULL,
                residential_units integer NULL,
                commercial_units integer NULL,
                total_units integer NULL,
                land_square_feet varchar(255) NULL,
                gross_square_feet varchar(255) NULL,
                year_built integer NULL,
                tax_class_at_time_of_sale integer NULL,
                building_class_at_time_of_sale varchar(255) NULL,
                sale_price varchar(255) NULL,
                sale_date date NULL
            );
        """)
        truncate_table = PostgresOperator(task_id="truncate_airbnb_table", postgres_conn_id='aize_db', sql="""
            TRUNCATE TABLE public.property_sales_ny;
        """)
        ingest_property_data = PythonOperator(task_id='ingest_property_data', python_callable=ingest_data, op_args=[
            """ 
            COPY public.property_sales_ny FROM STDIN WITH (FORMAT CSV, DELIMITER ',',  HEADER true)
            """,
            "Property_sales_data_New_York.csv"
        ])        

        with TaskGroup(group_id="transformations") as transformations:
            transform_land_square_feet = PostgresOperator(
                task_id='transform_land_square_feet',
                postgres_conn_id='aize_db',
                sql="""
                    UPDATE public.property_sales_ny
                    SET land_square_feet = NULL
                    WHERE land_square_feet = ' -  ';
                    
                    ALTER TABLE public.property_sales_ny ALTER COLUMN land_square_feet TYPE integer USING land_square_feet::integer;
                """
            )
            transform_gross_square_feet = PostgresOperator(
                task_id='transform_gross_square_feet',
                postgres_conn_id='aize_db',
                sql="""
                    UPDATE public.property_sales_ny
                    SET gross_square_feet = NULL
                    WHERE gross_square_feet = ' -  ';
                    
                    ALTER TABLE public.property_sales_ny ALTER COLUMN gross_square_feet TYPE integer USING gross_square_feet::integer;
                """
            )
            transform_sale_price = PostgresOperator(
                task_id='transform_sale_price',
                postgres_conn_id='aize_db',
                sql="""
                    UPDATE public.property_sales_ny
                    SET sale_price = NULL
                    WHERE sale_price = ' -  ';
                    
                    ALTER TABLE public.property_sales_ny ALTER COLUMN sale_price TYPE int8 USING sale_price::int8;
                """
            )
            fill_in_neighborhood_group = PostgresOperator(
                task_id='fill_in_neighborhood_group',
                postgres_conn_id='aize_db',
                sql="""
                    ALTER TABLE property_sales_ny ADD neighborhood_group varchar(255) NULL;
                    UPDATE public.property_sales_ny
                    SET neighborhood_group = (
                        CASE
                            WHEN borough = 1 THEN 'Manhattan'
                            WHEN borough = 2 THEN 'Bronx'
                            WHEN borough = 3 THEN 'Brooklyn'
                            WHEN borough = 4 THEN 'Queens'
                            WHEN borough = 5 THEN 'Staten Island'
                        END
                    )
                    WHERE neighborhood_group is NULL;
                """
            )

            transform_land_square_feet >> transform_gross_square_feet >> transform_sale_price >> fill_in_neighborhood_group

        create_property_sales_table >> truncate_table >> ingest_property_data >> transformations

    with TaskGroup(group_id='weather') as weather:
        create_weather_table = PostgresOperator(
            task_id="create_weather_table",
            postgres_conn_id='aize_db',
            sql="""
                DROP TABLE IF EXISTS public.weather_data;
                CREATE TABLE public.weather_data (
                    "timestamp" date NULL,
                    max real NULL,
                    min real NULL,
                    mean real NULL
                );
            """
        )
        truncate_weather_table = PostgresOperator(task_id="truncate_weather_table", postgres_conn_id='aize_db', sql="""
            TRUNCATE TABLE public.weather_data;
        """)
        ingest_weather_data = PythonOperator(task_id='ingest_weather_data', python_callable=ingest_data, op_args=[
            """ 
            COPY public.weather_data FROM STDIN WITH (FORMAT CSV, DELIMITER ',',  HEADER true)
            """,
            "Weather Data.csv"
        ])

        create_weather_table >> truncate_weather_table >> ingest_weather_data

    end = EmptyOperator(task_id='end')
    start >> normalize_headers >> [airbnb, property_sales, weather] >> end