DROP FUNCTION IF EXISTS plpyodk.entities_delete(uuid_ uuid, entity_list_name_ text, project_id_ integer);

CREATE OR REPLACE FUNCTION plpyodk.entities_delete(
		uuid_ uuid default null::uuid, 
		entity_list_name_ text default null::text, 
		project_id_ integer default null::integer
	)
    RETURNS text
    LANGUAGE 'plpython3u'
AS $BODY$
	from pyodk.client import Client
	client = Client()
	entity = client.entities.delete(uuid = uuid_, entity_list_name = entity_list_name_, project_id = project_id_)
	return(entity)
$BODY$;

COMMENT ON FUNCTION plpyodk.entities_delete(uuid_ uuid, entity_list_name_ text, project_id_ integer) IS 'delete an entity.';

-- SELECT plpyodk.entities_delete('dc2c7d3b-c4ee-4f93-b4f0-8f19441fc3af'::uuid, 'mares', 3);