DROP FUNCTION IF EXISTS plpyodk.projects_list();

CREATE OR REPLACE FUNCTION plpyodk.projects_list()
    RETURNS json[]
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	import json
	from pyodk.client import Client
	client = Client()
	projects = client.projects.list()
	projects_list = []

	for project in projects:
		projects_list.append(json.dumps(dict(project),sort_keys = True, default = str))
	 
	return(projects_list)
	
$BODY$;

COMMENT ON FUNCTION plpyodk.projects_list() IS 'returns an json array of each project description';

/*
Voir comment surcharger les paramètres de connexion à Central pour contacvte rune autre serveur avec d'autres identifiant *
avec utilisation des lavalurs par défaut du fichier de conf .toml
/*