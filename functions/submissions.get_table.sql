DROP FUNCTION IF EXISTS plpyodk.submissions_get_table(form_id_ text, project_id_ integer, table_name_ text, skip_ integer, top_ integer, count_ integer, wkt_ boolean, filter_ text, expand_ text);

CREATE OR REPLACE FUNCTION plpyodk.submissions_get_table(
		form_id_ text , 
		project_id_ integer, 
		table_name_ text default 'Submissions', 
		skip_ integer default null::integer, 
		top_ integer default null::integer, 
		count_ integer default null::integer, 
		wkt_ boolean default null::boolean, 
		filter_ text default null::text, 
		expand_ text default null::text
	)
    RETURNS json
    LANGUAGE 'plpython3u'
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	table_data = client.submissions.get_table(form_id = form_id_, project_id = project_id_, table_name = table_name_, skip = skip_, top = top_, count = count_, wkt = wkt_, filter = filter_, expand = expand_)
	return(json.dumps(table_data,sort_keys = True, default = str))
$BODY$;

COMMENT ON FUNCTION plpyodk.submissions_get_table(form_id_ text, project_id_ integer, table_name_ text, skip_ integer, top_ integer, count_ integer, wkt_ boolean, filter_ text, expand_ text) IS 'returns table data as a json';

SELECT plpyodk.submissions_get_table('Crabe_bleu'::text, 5, 'Submissions', null::integer, null::integer, null::integer, null::boolean, null::text, null::text)