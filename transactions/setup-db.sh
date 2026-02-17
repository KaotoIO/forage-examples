#!/bin/bash
# Setup database schema for the XA Transactions example
# Requires: PostgreSQL running on localhost:5432 (start with: camel infra run postgres)

set -e

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-test}"
PGPASSWORD="${PGPASSWORD:-test}"
PGDATABASE="${PGDATABASE:-postgres}"

export PGPASSWORD

echo "Creating XA Transactions schema on ${PGHOST}:${PGPORT}/${PGDATABASE}..."

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<'SQL'
CREATE TABLE IF NOT EXISTS test (
    id INTEGER PRIMARY KEY,
    action VARCHAR(255)
);
SQL

echo "XA Transactions schema created successfully."
