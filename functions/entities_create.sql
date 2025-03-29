DROP FUNCTION IF EXISTS plpyodk.entities_create(label_ text, data_ json, entity_list_name_ text, project_id_ integer, uuid_ uuid);

CREATE OR REPLACE FUNCTION plpyodk.entities_create(
		label_ text,
		data_ json, 
		entity_list_name_ text default null::text, 
		project_id_ integer default null::integer, 
		uuid_ uuid default null::uuid
	)
    RETURNS text
    LANGUAGE 'plpython3u'
AS $BODY$
	from pyodk.client import Client
	import json
	client = Client()
	entity = client.entities.create(label = label_, data = json.loads(data_), entity_list_name = entity_list_name_, project_id = project_id_, uuid = uuid_)
	return(entity)
$BODY$;

COMMENT ON FUNCTION plpyodk.entities_create(label_ text, data_ json, entity_list_name_ text, project_id_ integer, uuid_ uuid) IS 'creates an entity. Uses json.loads to tranform the json into a python dict';

-- SELECT plpyodk.entities_create('lavogne 1', '{"surface": "12"}'::json, 'mares', 18, null::uuid)