DROP FUNCTION IF EXISTS plpyodk.submissions_get(instance_id_ text, form_id_ text, project_id_ integer);

CREATE OR REPLACE FUNCTION plpyodk.submissions_get(instance_id_ text, form_id_ text, project_id_ integer)
    RETURNS json
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	submission_metadata = client.submissions.get(instance_id = instance_id_, form_id = form_id_, project_id = project_id_)
	 
	return(json.dumps(dict(submission_metadata),sort_keys = True, default = str))

$BODY$;

COMMENT ON FUNCTION plpyodk.submissions_get(instance_id_ text, form_id_ text, project_id_ integer) IS 'returns submission''s metadata';