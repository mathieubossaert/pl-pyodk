-- FUNCTION: plpyodk.does_table_exists(text, text)

-- DROP FUNCTION IF EXISTS plpyodk.does_table_exists(text, text);

CREATE OR REPLACE FUNCTION plpyodk.does_table_exists(
	schemaname text,
	tablename text)
    RETURNS boolean
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
		SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE  table_schema = $1
   AND    table_name   = $2
   );
	
$BODY$;

COMMENT ON FUNCTION plpyodk.does_table_exists(text, text)
    IS 'description : 
	checks if a table exists given its name and schema name
	
	parameters :
	schemaname text 		-- the name of the schema
	tablename text		-- the name of the table
	
	returning :
	boolean';