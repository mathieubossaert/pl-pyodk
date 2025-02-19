-- FUNCTION: plpyodk.odk_central_to_pg(integer, text, text, text, text)

-- DROP FUNCTION IF EXISTS plpyodk.odk_central_to_pg(integer, text, text, text, text);

CREATE OR REPLACE FUNCTION plpyodk.odk_central_to_pg(
	project_id integer,
	form_id text,
	destination_schema_name text,
	criteria text,
	geojson_columns text)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
EXECUTE format('DROP TABLE IF EXISTS '||destination_schema_name||'.'||split_part(form_id,'/draft',1)||';
	CREATE TABLE IF NOT EXISTS '||destination_schema_name||'.'||split_part(form_id,'/draft',1)||' AS
	SELECT key as tablename, (json_array_elements(value)) as json_data
	FROM json_each(plpyodk.get_complete_submissions_with_filter('''||project_id||'''::text, '''||form_id||'''::text,'''||criteria||'''::text)::json)
');

RAISE INFO '
Datas pulled from Central. Let''s feed the dedicated tables...
'; 

EXECUTE format('SELECT plpyodk.feed_data_tables_from_central('''||destination_schema_name||''', '''||split_part(form_id,'/draft',1)||''', '''||geojson_columns||''');'
);
RETURN true;
END;
$BODY$;