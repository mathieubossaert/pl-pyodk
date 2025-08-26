-- FUNCTION: plpyodk.get_complete_submissions_with_filter(text, text, text)

-- DROP FUNCTION IF EXISTS plpyodk.get_complete_submissions_with_filter(text, text, text);

CREATE OR REPLACE FUNCTION plpyodk.get_complete_submissions_with_filter(
	project_id text,
	form_id text,
	filter text)
    RETURNS text
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
import collections.abc

def update(d):
    for k, v in d.items():
        if isinstance(v, collections.abc.Mapping):
            d[k] = update(v)
        else:
            if isinstance(v, str):
                d[k] = v.replace('"', '')
            else:
                d[k] = v
    return d
	
def fresh_data_only(pid, fid, path, filter, datas):
    from pyodk.client import Client
    import re
    import json 
    client = Client()
    client.open()
    if path == '':
        return None

    if not filter:
        url = 'projects/'+pid+'/forms/'+fid+'.svc/'+path
    else:
        url = 'projects/'+pid+'/forms/'+fid+'.svc/'+path+'?$filter='+filter   
    
    if re.match(r"Submissions\?.*", path) or re.match(r".*\)$", path):
        tablename = 'submissions'
    else:
        tablename = path.rsplit('/')[-1]    
    
    response = client.get(url)
    response.raise_for_status()

    value = [update(elem) for elem in response.json()['value']]
    
    navigationlinks = re.findall(r'\'\w+@odata\.navigationLink\':\s+"([^"}]*)', str(value))
    result = list(dict.fromkeys(navigationlinks))
    for (link) in navigationlinks:
        link = link.replace("'", "'").replace('"','')
        fresh_data_only(project_id, form_id, link, '', datas)
    
    if tablename in datas.keys():
        datas[tablename] += value
    else:
        datas[tablename]=value
		
    json_datas = str(json.dumps(datas))
    return json_datas.encode(encoding='utf-8').decode('unicode_escape')
	
return fresh_data_only(project_id, form_id, 'Submissions', filter, datas = {}).replace('\n', '\\n')

$BODY$;
