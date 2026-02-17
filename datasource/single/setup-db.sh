#!/bin/bash
# Setup database schema for the Single Datasource example
# Requires: PostgreSQL running on localhost:5432 (start with: camel infra run postgres)

set -e

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-test}"
PGPASSWORD="${PGPASSWORD:-test}"
PGDATABASE="${PGDATABASE:-postgres}"

export PGPASSWORD

echo "Creating Single Datasource schema on ${PGHOST}:${PGPORT}/${PGDATABASE}..."

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<'SQL'
CREATE TABLE IF NOT EXISTS bar (
    id INTEGER PRIMARY KEY,
    content VARCHAR(255)
);

INSERT INTO bar VALUES (1, 'postgres 1') ON CONFLICT (id) DO NOTHING;
INSERT INTO bar VALUES (2, 'postgres 2') ON CONFLICT (id) DO NOTHING;
SQL

echo "Single Datasource schema created successfully."
