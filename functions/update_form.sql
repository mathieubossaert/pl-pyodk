-- FUNCTION: plpyodk.update_form(text, text, text[])

-- DROP FUNCTION IF EXISTS plpyodk.update_form(text, text, text[]);

CREATE OR REPLACE FUNCTION plpyodk.update_form(
	project_id text,
	form_id text,
	paths text[])
    RETURNS text
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
def update_form(pid, fid, attachments_paths):
	from pyodk.client import Client
	with Client(project_id=pid) as client:
		client.forms.update(
			form_id=fid,
			attachments=attachments_paths)
	
return update_form(project_id, form_id, paths)

$BODY$;