# pyODK in PostgreSQL using plpython3 extension

## install plpython
```bash
apt-get update && apt-get install postgresql-plpython3-12
```
## pip install (if not yet)
```bash
apt install python3-pip
```
## pyODK install
```
pip install pyodk
```

## Connecting to the database
### plpython3 installation

```sql
CREATE OR REPLACE PROCEDURAL LANGUAGE plpython3u
    HANDLER plpython3_call_handler
    INLINE plpython3_inline_handler
    VALIDATOR plpython3_validator;
```

### First try : project_list
```sql
CREATE OR REPLACE FUNCTION client_project_list()
RETURNS TEXT
AS $$
	from pyodk.client import Client

	client = Client()
	client.open()
	json_value = client.projects.list()
	return json_value
$$
LANGUAGE 'plpython3u';

SELECT client_project_list();
```

### Get data filtered according to a date, a validation status...

```sql
CREATE OR REPLACE FUNCTION plpyodk.get_filtered_complete_submissions(
	project_id text,
	form_id text,
	filter text)
    RETURNS text
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
def fresh_data_only(pid, fid, path, filter, datas):
    from pyodk.client import Client
    import re
    import json 
    client = Client()
    client.open()
    if path == '':
        return None

    url = 'projects/'+pid+'/forms/'+fid+'.svc/'+path+'?$filter='+filter
    if re.match(r"Submissions\?.*", path) or re.match(r".*\)$", path):
        tablename = 'submissions'
    else:
        tablename = path.rsplit('/')[-1]    
    
    response = client.get(url)
    
    value = response.json()['value']
    
    navigationlinks = re.findall(r'(\'\w+@odata\.navigationLink\'):\s+([^\}]+)', str(value))
    for (key, link) in navigationlinks:
        link = link.replace("'", "'").replace('"','')
        fresh_data_only(project_id, form_id, link, '', datas)
    
    if tablename in datas.keys():
        datas[tablename] += value
    else:
        datas[tablename]=value
		
    json_datas = json.dumps(datas, indent = 4) 
    return json_datas
	
return fresh_data_only(project_id, form_id, 'Submissions', filter, datas = {})

$BODY$;
```

### Get table list of a form
```sql

CREATE OR REPLACE FUNCTION plpyodk.form_detail()
RETURNS text[]
AS $$
from pyodk.client import Client

client = Client()
client.open()
url ='projects/5/forms/Sicen_2022.svc'
response = client.get(url)
tables = []
for s in (response.json()['value']):
  tables.append(s['name'].rsplit('.')[-1])
return tables
$$
LANGUAGE 'plpython3u';

--SELECT unnest(plpyodk.form_detail()) as tablename
```

### On crée la table des données fraîches à intégrer

```sql
CREATE TABLE odk_central.sicen_2022 AS
SELECT key as tablename, (json_array_elements(value)) as json_data
FROM json_each(plpyodk.get_filtered_complete_submissions('5', 'Sicen_2022','__system/submissionDate ge 2023-03-11')::json)
```
### test
```sql
SELECT * from odk_central.sicen_2022
```

locate pyodk_config.toml