# PostGIS docker image to try pyODK in pl/python function

```sh
sudo docker build -t postgis:test_pyodk .
sudo docker run --restart="always" --name postgis_v15_3 -e POSTGRES_PASSWORD=dbroot -d -p 5555:5432 postgis:test_pyodk
```

```sql
TRUNCATE odk_central.sicen_2022;
TRUNCATE odk_central.sicen_2022_emplacements_data;
TRUNCATE odk_central.sicen_2022_observations_data;
TRUNCATE odk_central.sicen_2022_submissions_data;
SELECT plpyodk.odk_central_to_pg2(5,'Sicen_2022'::text,'odk_central'::text,'__system/submissionDate ge 2023-04-01','point,ligne,polygone'::text);
SELECT * FROM odk_central.sicen_2022_observations_data;
```