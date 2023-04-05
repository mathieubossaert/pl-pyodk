# First version of functions that automatically get data from ODK central using a filter
-> for example from last submission_date known in the database

Central gives all datas by default.
We use ODK every day to collect data that goes and is edited in our own GIS database.
Each day we download hourly a lot of data that are already consolidated into our GIS. It consumes a lot of bandwidth and energy to run, at least too much.

Tnaks to [pyODK](https://getodk.github.io/pyodk/) and pl/python We can now ask central for the only data that are not already in our database, so maybe 30 or 40 submissions instead of 5000 ;-)

## Requirements
### pl/python langage installed on you databse
```sql
CREATE OR REPLACE PROCEDURAL LANGUAGE plpython3u;
```
### Install pyodk on the database host
On the database server
```sh
pip install -U pyodk
```
### Set pyODK config file
Edit the .template_pyodk_config.toml file and save it as .pyodk_config.toml
.pyodk_config.toml conf file must exists in Postgresql directory (ie /var/lib/postgresql/)


```toml
[central]
base_url = "https://my_central_server.url"
username = "my_username"
password = "my_password"
default_project_id = 5
```

## Using the docker image for test
#### Set pyODK config file

```sh
cd docker_postgis_curl_plpython_pgcron
```

Edit the .template_pyodk_config.toml file and save it as .pyodk_config.toml

```sh
sudo docker build -t postgis:test_pyodk .
sudo docker run --restart="always" --dns 1.1.1.1 --name test_plpyodk -e POSTGRES_DB=field_data -e POSTGRES_USER=tester -e POSTGRES_PASSWORD=testerpwd -d -p 5555:5432 postgis:test_pyodk
```

You can now connect to the **field_data** database on **localhost**, port **5555** with user **tester** and password **testerdb**

And test with the form you want from your central server :

```sql
/*
SELECT plpyodk.odk_central_to_pg(
	5, 					-- the project id, 
	'waypoint',			-- form ID
	'odk_central',				-- schema where to creta tables and store data
	'point_auto_5,point_auto_10,point_auto_15,point,ligne,polygone'	-- columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
);
*/

SELECT plpyodk.odk_central_to_pg(5,'waypoint'::text,'odk_central'::text,'','point_auto_5,point_auto_10,point_auto_15,point,ligne,polygone'::text);

```
The form definition may be found here :

https://biodiversityforms.org/assets/files/ODKWaypoints-95fef9d5cc12bc1d91dca309fa53a242.xlsx
