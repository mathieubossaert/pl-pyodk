DROP FUNCTION IF EXISTS plpyodk.projects_get(project_id_ integer);

CREATE OR REPLACE FUNCTION plpyodk.projects_get(project_id_ integer default null::integer)
    RETURNS json
    LANGUAGE 'plpython3u'
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	project = client.projects.get(project_id = project_id_)
	
	return(json.dumps(dict(project),sort_keys = True, default = str))

$BODY$;

COMMENT ON FUNCTION plpyodk.projects_get(project_id_ integer) IS 'returns an json of the project metatada';