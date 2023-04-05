# First version of functions that automatically get data from ODK central using a filter
-> for example from last submission_date known in the database
Central gives all datas by default. We use ODK every day to collect data that goes and is edited in our own GIS database.
Each day we download hourly a lot of data that are already consolidated into our GIS. It consumes a lot, at least too much, bandwidth and energy to run.
We can now ask central for the only data that are not already in our database, so maybe 30 or 40 submissions instead of 5000 ;-)
## Requirements
### pl/python langage installed on you databse
```sql
CREATE OR REPLACE PROCEDURAL LANGUAGE plpython3u;
```
## Example
### pip install pyodk
On the database server
```sh
pip install -U pyodk
```
### pyODK config file
.pyodk_config.toml conf file must exists in Postgresql directory (ie /var/lib/postgresql/)
Edit the .template_pyodk_config.toml file

```toml
[central]
base_url = "https://my_central_server.url"
username = "my_username"
password = "my_password"
default_project_id = 5
```
