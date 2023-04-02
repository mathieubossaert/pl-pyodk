#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Load PostGIS into both template_database and $POSTGRES_DB
echo "Running plpyodk script into database field_data"
"${psql[@]}" --dbname="field_data" -f /var/lib/postgresql/pl-pyODK.sql

