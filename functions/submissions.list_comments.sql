DROP FUNCTION IF EXISTS plpyodk.submissions_list_comments(instance_id text, form_id text, project_id integer);

CREATE OR REPLACE FUNCTION plpyodk.submissions_list_comments(instance_id text, form_id text, project_id integer)
    RETURNS json[]
    LANGUAGE 'plpython3u'
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	submission_comments = client.submissions.list_comments(instance_id, str(form_id), project_id)
	comments_list = []

	for comment in submission_comments:
		comments_list.append(json.dumps(dict(comment),sort_keys = True, default = str))

	return(comments_list)

$BODY$;

COMMENT ON FUNCTION plpyodk.submissions_list_comments(instance_id text, form_id text, project_id integer) IS 'returns an json array of each submission metadata';