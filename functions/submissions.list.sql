DROP FUNCTION IF EXISTS plpyodk.submissions_list(form_id text, project_id integer);

CREATE OR REPLACE FUNCTION plpyodk.submissions_list(form_id text, project_id integer)
    RETURNS json[]
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	submissions = client.submissions.list(form_id, project_id)
	submissions_list = []

	for submission in submissions:
		submissions_list.append(json.dumps(dict(submission),sort_keys = True, default = str))
	 
	return(submissions_list)

$BODY$;

COMMENT ON FUNCTION plpyodk.submissions_list(form_id character varying, project_id integer) IS 'returns an json array of each submission metadata';