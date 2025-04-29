-- FUNCTION: plpyodk.create_table_from_refcursor(text, text, refcursor)

-- DROP FUNCTION IF EXISTS plpyodk.create_table_from_refcursor(text, text, refcursor);

CREATE OR REPLACE FUNCTION plpyodk.create_table_from_refcursor(
	_schema_name text,
	_table_name text,
	_ref refcursor)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
  _sql       text;
  _sql_index       text;
  _sql_val   text = '';
  _sql_existing_cols   text = '';
  _sql_new_cols   text = '';
  _row       record;
BEGIN
 RAISE INFO 'starting create_table_from_refcursor() for table %',lower(_table_name); 
    FETCH FIRST FROM _ref INTO _row;
    SELECT _sql_val || '
           (' ||
           STRING_AGG(concat('"',val.key :: text,'" text', CASE WHEN val.key = 'data_id' THEN ' PRIMARY KEY' ELSE NULL::text END), ',') ||
           ')'
        INTO _sql_val
    FROM JSON_EACH(TO_JSON(_row)) val;
  _sql = '
          CREATE TABLE IF NOT EXISTS ' || _schema_name ||'.'|| lower(_table_name) || '
          ' || _sql_val;
          
-- RAISE INFO 'SQL script for table cration %',_sql; 
    EXECUTE (_sql);
	
	/* adding new columns if table already exixts */
	SELECT _sql_new_cols || 
           STRING_AGG(concat('ALTER TABLE ' , _schema_name ,'.', lower(_table_name) , ' ADD COLUMN IF NOT EXISTS "',val.key :: text,'" text'), ';') ||';'
        INTO _sql_new_cols
    FROM JSON_EACH(TO_JSON(_row)) val
	WHERE val.key NOT IN ( SELECT attname 
 FROM pg_class JOIN pg_attribute ON pg_attribute.attrelid=pg_class.oid
 JOIN pg_namespace ON relnamespace = pg_namespace.oid
 WHERE nspname = _schema_name
   AND relkind = 'r' AND pg_class.relname = lower(_table_name) AND attnum > 0 AND attname = val.key
) AND plpyodk.does_table_exists(_schema_name, lower(_table_name));
-- Create new attributes or Run a dummy query if nothing new
RAISE INFO 'SQL script for new cols %',_sql_new_cols; 
    EXECUTE (COALESCE(_sql_new_cols,'SELECT true;')); 
 RAISE INFO 'exiting from  create_table_from_refcursor() for table %',lower(_table_name); 
RAISE INFO 'create_table_from_refcursor(): SQL statement is: %', COALESCE(_sql_new_cols,'no new column to add');
END;
$BODY$;

COMMENT ON FUNCTION plpyodk.create_table_from_refcursor(text, text, refcursor)
    IS 'description : 
	-> inspired by https://stackoverflow.com/questions/50837548/insert-into-fetch-all-from-cant-be-compiled/52889381#52889381
	Create a table corresponding to the cursor structure (attribute types and names). As json atributes are not typed, all attributes are created as text ones.
	You''ll need to cast each in your subsequent requests.
	
	parameters :
	_table_name text 		-- the name of the table to create
	_ref refcursor			-- the name of the refcursor to get data from
	
	returning :
	void';