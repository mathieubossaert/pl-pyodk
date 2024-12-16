[English version here](README.md)

> **Warning**
> Cet ensemble de fonctions n'est pas un projet de getODK, mais un projet personnel. Les équipes d'ODK n'apporterons pas de support à leur sujet.
> Merci de d'utiliser Github pour échanger sur les besoins ou les difficultées que vous rencontrerez dans leur utilisation

# pl-pyODK
## Transformer automatiquement les données de vos formulaires ODK en tables au sein de votre propre base de données.
Ceci est une première version d'un ensemble de fonctions permettant d'extraire les données d'ODK Central, acceptant un filtre, et qui créent automatiquement des tables dédiées dans votre base de données PostgreSQL.
-> par exemple les données soumises depuis la dernière date de soumission connue en base (seulement les nouvelles données)

[ODK Central](https://docs.getodk.org/central-intro/) retourne toutes les données par défaut.
Nous utilisons [ODK Collect](https://docs.getodk.org/collect-intro/) tous les jours pour collecter des données qui vont et sont éditées dans notre propre base de données [PostGIS](https://postgis.net).
Chaque jour, nous téléchargeons toutes les heures un grand nombre de données avec [Central2pg](https://github.com/mathieubossaert/central2pg).
Cela fonctionne très bien, mais la plupart des données téléchargées ont déjà été consolidées dans notre base de données SIG. Nous n'avons besoin que des données nouvellement créées.

Grâce à [pyODK](https://getodk.github.io/pyodk/) et [pl/python](https://www.postgresql.org/docs/current/plpython.html) nous pouvons maintenant demander à Central les seules données qui ne sont pas déjà dans notre base de données, donc peut-être 30 ou 40 soumissions au lieu de 5000 ;-)

pl/pyDOK dans la chaine de traitements :

![pl-pyODK_in_the_data_flow](./pl-pyODK_in_the_data_flow.png)

# Comment l'utiliser
Vous avez deux options : 
1. Installer pl-pyODK et ses pré-requis sur votre base de données -> [ici](https://github.com/mathieubossaert/pl-pyodk/blob/main/README_FR.md#1-utilisation-sur-votre-propre-serveur)
2. Ou utiliser l'image docker (à des fins de test uniquement) -> [là](https://github.com/mathieubossaert/pl-pyodk/blob/main/README_FR.md#2-utilisation-de-limage-docker-pour-tests-uniquement)

## 1. Utilisation sur votre propre serveur

### Prérequis
#### pl/python doit être installé dans votre base de données
```sql
CREATE OR REPLACE PROCEDURAL LANGUAGE plpython3u;
```
### Installation

#### Installer la librairie pyodk sur l'hôte de votre serveur de base de données

Sur votre serveur
```sh
pip install -U pyodk
```
#### Paramétrer le fichier de configuration de pyodk

Editer le fichier .template_pyodk_config.toml et l'enregistrer en tant que .pyodk_config.toml

Le fichier .pyodk_config.toml doit exister dans le répertoire de Postgresql (ie /var/lib/postgresql/)


```toml
[central]
base_url = "https://my_central_server.url"
username = "my_username"
password = "my_password"
default_project_id = 5
```
#### Exécuter le script sql dans votre base de données
```sh
psql -f pl-pyODK.sql -U my_ser my_database
```

#### Maintenant vous pouvez jouer avec le SQL
[ci-dessous](https://github.com/mathieubossaert/pl-pyodk/blob/main/README_FR.md#executez-des-requ%C3%AAtes-sql-pour-r%C3%A9cup%C3%A9rer-des-donn%C3%A9es-de-central-et-faites-en-ce-que-vous-voudrez-dans-votre-propre-base-de-donn%C3%A9es)

## 2. Utilisation de l'image docker pour tests (uniquement)
### Set pyODK config file

```sh
cd docker_postgis_curl_plpython_pgcron
```

Editer le fichier .template_pyodk_config.toml et l'enegistrer en tant que .pyodk_config.toml

### Construire et lancer le conteneur (Build and run)

```sh
sudo docker build -t postgis:test_pyodk .
sudo docker run --restart="always" --dns 1.1.1.1 --name test_plpyodk -e POSTGRES_DB=field_data -e POSTGRES_USER=tester -e POSTGRES_PASSWORD=testerpwd -d -p 5555:5432 postgis:test_pyodk
```
### Connection à la base de données

Vous pouvez maintenant vous connecter à la base de données avec votre client préféré :
* host = **localhost**
* port = 5555
* user = **tester**
* password = **testerpwd**
* dbname = **field_data**

### Executez des requêtes SQL pour récupérer des données de Central et faites en ce que vous voudrez dans votre propre base de données.

Testez avec le formulaire de votre choix sur votre serveur ODK Central :

```sql
SELECT plpyodk.odk_central_to_pg(
	3,                  -- the project id, 
	'waypoint',         -- form ID
	'odk_central',      -- schema where to create tables and store data
	'filter_to_use',    -- the filter "clause" used in the API call ex. '__system/submissionDate ge 2023-04-01'. Empty string ('') will get all the datas. 
	'point_auto_5,point_auto_10,point_auto_15,point,ligne,polygone'	-- (geo)columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
);
```

Ou essayez l'exemple ci-dessus, qui utilise ce formulaire : https://biodiversityforms.org/docs/ODK-CEN/donnees_opportunistes/ODK_waypoints

1. Téléchargez-le d'abord sur votre serveur central, notez l'identifiant du projet (3 dans notre cas), l'identifiant du formulaire (waypoint), et le nom de chaque question "géographique" dans le formulaire (point_auto_5,point_auto_10,point_auto_15,point,ligne,polygone)
.
2. Envoyer quelques soumissions à Central.

3. Vous êtes maintenant prêt à effectuer le premier appel, qui téléchargera toutes les données soumises pour ce formulaire. Le paramètre "filter" peut être défini comme une chaîne vide.

```sql
SELECT plpyodk.odk_central_to_pg(
	3,                    -- the project id
	'waypoint'::text,     -- form ID
	'odk_central'::text,  -- schema where to create tables and store data
	'',                   -- the filter "clause" used in the API call
	'point_auto_5,point_auto_10,point_auto_15,point,ligne,polygone'::text -- json (geo)columns to ignore
);
```

Cela va automatiquement :

 * demander à Central les soumissions du formulaire correpondant au filtre (si filtre)
 * obtenir les données
 * créer les tables correspondant aux soumissions et au "repeat group" dans le schéma "odk_data" de ma base de données. Un attribut texte par question du formulaire pour stocker ces données 
 * le dernier paramètre liste la question à ignorer dans la récusrion de l'exploration json (colonnes geowidgets)
 * alimenter ces tables avec les données récupérées

Et au prochain appel :

 * vérifier la présence de nouvelles questions dans le formulaire
 * les créer dans les tables le cas échéant si nécessaire
 * insérer les nouvelles données (seulement celles non encore présente)


4. Vérifiez les données reçues de Central
```sql
SELECT * FROM odk_central.waypoint_submissions_data
SELECT * FROM odk_central.waypoint_emplacements_data;
```
5. Nous pouvons maintenant effectuer une requête qui utilise la date de la dernière soumission (colonne "submissionDate") comme paramètre dans l'appel de la fonction.
```sql
-- ou ceci pour obtenir uniquement les données collectées depuis la dernière date de soumission connue dans la base de données

CREATE MATERIALIZED VIEW IF NOT EXISTS odk_central.waypoint_last_submission_date AS 
	SELECT max("submissionDate")::text AS last_submission_date
	FROM odk_central.waypoint_submissions_data;

REFRESH MATERIALIZED VIEW odk_central.waypoint_last_submission_date;

SELECT plpyodk.odk_central_to_pg(
	3,
	'waypoint'::text,
	'odk_central'::text,
	concat('__system/submissionDate ge ',last_submission_date),
	'point_auto_5,point_auto_10,point_auto_15,point,ligne,polygone'::text
)
FROM odk_central.waypoint_last_submission_date;
```
6. Envoyez les nouvelles soumissions à Central
7. Exécutez la dernière requête à la fréquence que vous souhaitez, manuellement
Vous pouvez enregistrer votre script dans un fichier sql comme **get_waypoint_data.sql** et l'appeler ensuite avec psql :
```sh
psql -h localhost -p 5555 -U tester -f get_waypoint_data.sql -d field_data
```
8. Vous pouvez également définir une tâche planifiée (cron)
Adaptez et ajoutez une ligne comme ci-dessus à votre cron tab. Consultez le site https://crontab.guru/ pour en savoir plus sur la planification des tâches cron.
```bash
crontab -e
```
Par exemple, pour exécuter le script tous les jours à 18h00, ajoutez cette ligne à votre crontab :
> 0 18 * * *  psql -h localhost -p 5555 -U tester -f get_waypoint_data.sql -d field_data

## Comment afficher des données sur une carte avec QGIS
### Création de vues
```sql
CREATE VIEW waypoints AS 
SELECT places.data_id, date_heure, mail_observateur as email, nom_observateur, etiquette, heure_localite, 
st_force2d(st_geomfromgeojson(replace(COALESCE(ligne, point, point_auto_10, point_auto_15, point_auto_5, polygone),'\','')))::geometry(geometry, 4326) AS geom, prise_image, remarque
FROM odk_central.waypoint_submissions_data submissions JOIN  odk_central.waypoint_emplacements_data places ON places."__Submissions-id" = submissions."__id"
```

### Configurer la source de données PostGIS dans QGIS

![QGIS_datasource_definition](./QGIS_datasource_definition.png)

### Connecter et ajouter la vue public.waypoints en tant que "couche" au canevas

![load_waypoints_view_to_the_canvas.png](./load_waypoints_view_to_the_canvas.png)

![see_waypoints_on_the_map](./see_waypoints_on_the_map.png)

### Exécutez à nouveau les étapes 6 et 7 puis rafraîchir le canevas QGIS ;-)

[English version here](README.md)