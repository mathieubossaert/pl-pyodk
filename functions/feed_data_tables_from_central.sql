-- FUNCTION: plpyodk.feed_data_tables_from_central(text, text, text)

-- DROP FUNCTION IF EXISTS plpyodk.feed_data_tables_from_central(text, text, text);

CREATE OR REPLACE FUNCTION plpyodk.feed_data_tables_from_central(
	schema_name text,
	form_id text,
	geojson_columns text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
--declare keys_to_ignore text;
declare 
	non_empty boolean;
	t record;
	query text;

BEGIN

query := 'select DISTINCT tablename	FROM '||schema_name||'.'||form_id;

	for t in execute query
	loop

	EXECUTE format('SELECT exists(select 1 FROM %1$s.%2$s WHERE tablename = ''%3$s'') ', schema_name, form_id, t.tablename)
	INTO non_empty;
		IF non_empty THEN 
		RAISE INFO '
-> Entering feed_data_tables_from_central for table % :', t.tablename; 
		EXECUTE format('DROP TABLE IF EXISTS data_table;
			CREATE TABLE data_table(tablename text, data_id text, key text, value json);
			INSERT INTO  data_table(tablename, data_id, key, value) 
			WITH RECURSIVE doc_key_and_value_recursive(tablename, data_id, key, value) AS (
			  SELECT tablename, 
				(json_data ->> ''__id'') AS data_id,
				t.key,
				t.value
			  FROM datas, json_each(json_data) AS t
			  UNION ALL
			  SELECT tablename, 
				doc_key_and_value_recursive.data_id,
				t.key,
				t.value
			  FROM doc_key_and_value_recursive,
				json_each(CASE 
				  WHEN json_typeof(doc_key_and_value_recursive.value) <> ''object'' 
						  OR key = ANY(string_to_array('''||geojson_columns||''','','')) 
						  THEN ''{}'' :: JSON
				  ELSE doc_key_and_value_recursive.value
				END) AS t
			), datas AS (
			SELECT tablename, json_data
		FROM '||schema_name||'.'||form_id||' WHERE tablename = '''||t.tablename||'''
					  ) SELECT tablename, data_id, key, value FROM doc_key_and_value_recursive WHERE json_typeof(value) <> ''object'' OR key = ANY(string_to_array('''||geojson_columns||''','','')) ORDER BY 2,1;'
		);

				EXECUTE format('SELECT plpyodk.dynamic_pivot(''SELECT data_id, key, value FROM data_table ORDER BY 1,2'',''SELECT DISTINCT key FROM data_table ORDER BY 1'',''curseur_central'');
									SELECT plpyodk.create_table_from_refcursor('''||schema_name||''','''||form_id||'_'||t.tablename||'_data'', ''curseur_central'');
									MOVE BACKWARD FROM "curseur_central";
									SELECT plpyodk.insert_into_from_refcursor('''||schema_name||''','''||form_id||'_'||t.tablename||'_data'', ''curseur_central'');
									CLOSE "curseur_central"'
							  );	
				RAISE INFO '
-> exiting from feed_data_tables_from_central for table %.
', t.tablename; 

		ELSE
			RAISE INFO 'table % is empty !', t.tablename; 
		END IF;
    end loop;
END;
$BODY$;