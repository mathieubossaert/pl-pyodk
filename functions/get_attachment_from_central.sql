-- FUNCTION: plpyodk.get_attachment_from_central(text, text, text, text, text)

-- DROP FUNCTION IF EXISTS plpyodk.get_attachment_from_central(text, text, text, text, text);

CREATE OR REPLACE FUNCTION plpyodk.get_attachment_from_central(
	project_id text,
	form_id text,
	submission_id text,
	attachment text,
	destination text)
    RETURNS text
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
def save_attachment_to_file(pid, fid, sid, attachment, dest_path):
    from pyodk.client import Client

    client = Client()
    client.open()

    url ='projects/'+pid+'/forms/'+fid+'/Submissions/'+sid+'/attachments/'+attachment
    print(url)
    response = client.get(url)
    response.raise_for_status()
    
    with open(dest_path, "wb") as out_file:
        out_file.write(response.content)
    
save_attachment_to_file(project_id,	form_id, submission_id,	attachment,	destination)

$BODY$;