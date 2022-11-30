FROM  postgres:14
COPY create_airbnb_db.sql /docker-entrypoint-initdb.d/
EXPOSE 5432
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_user=deb

