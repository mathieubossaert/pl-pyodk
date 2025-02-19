DROP FUNCTION IF EXISTS plpyodk.projects_get(project_id integer);

CREATE OR REPLACE FUNCTION plpyodk.projects_get(project_id integer default null::integer)
    RETURNS json
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	project = client.projects.get(project_id)
	
	return(json.dumps(dict(project),sort_keys = True, default = str))

$BODY$;

COMMENT ON FUNCTION plpyodk.projects_get(project_id integer) IS 'returns an json of the project metatada';