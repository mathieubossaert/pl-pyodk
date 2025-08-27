DROP FUNCTION IF EXISTS plpyodk.entities_list(entity_list_name_ text, project_id_ integer);

CREATE OR REPLACE FUNCTION plpyodk.entities_list(
		entity_list_name_ text default null::text, 
		project_id_ integer default null::integer
	)
    RETURNS text[]
    LANGUAGE 'plpython3u'
AS $BODY$
	from pyodk.client import Client
	import json
	client = Client()
	list = client.entities.list(entity_list_name = entity_list_name_, project_id = project_id_)
	return(list)
$BODY$;

COMMENT ON FUNCTION plpyodk.entities_list(entity_list_name_ text, project_id_ integer) IS 'Read all Entity metadata';

--SELECT unnest(plpyodk.entities_list('mares_bidons', 18))