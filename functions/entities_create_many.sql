DROP FUNCTION IF EXISTS plpyodk.entities_create_many(data_ json, entity_list_name_ text, project_id_ integer, create_source_ text, source_size_ integer);

CREATE OR REPLACE FUNCTION plpyodk.entities_create_many(
		data_ json, 
		entity_list_name_ text default null::text, 
		project_id_ integer default null::integer, 
		create_source_ text default null::text, 
		source_size_ integer default null::integer
	)
    RETURNS boolean
    LANGUAGE 'plpython3u'
AS $BODY$
	from pyodk.client import Client
	import json
	client = Client()
	entity = client.entities.create_many(data = json.loads(data_), entity_list_name = entity_list_name_, project_id = project_id_, create_source = create_source_, source_size = source_size_)
	return(entity)
$BODY$;

COMMENT ON FUNCTION plpyodk.entities_create_many(data_ json, entity_list_name_ text, project_id_ integer, create_source_ text, source_size_ integer) IS 'creates many entities. Uses json.loads to tranform the json into a python dict';

SELECT plpyodk.entities_create_many('[{"label":"1","surface":"12"},{"label":"2","surface":"15"}]'::json, 'mares_bidons', 18, 'sicen'::text, 100)