#!/bin/bash
# Setup database schema for the Aggregation Repository example
# Requires: PostgreSQL running on localhost:5432 (start with: camel infra run postgres)

set -e

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-test}"
PGPASSWORD="${PGPASSWORD:-test}"
PGDATABASE="${PGDATABASE:-postgres}"

export PGPASSWORD

echo "Creating Aggregation Repository schema on ${PGHOST}:${PGPORT}/${PGDATABASE}..."

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<'SQL'
CREATE TABLE IF NOT EXISTS event_aggregation (
    id varchar(255) NOT NULL,
    exchange bytea NOT NULL,
    version BIGINT NOT NULL,
    CONSTRAINT event_aggregation_pk PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS event_aggregation_completed (
    id varchar(255) NOT NULL,
    exchange bytea NOT NULL,
    version BIGINT NOT NULL,
    CONSTRAINT event_aggregation_completed_pk PRIMARY KEY (id)
);
SQL

echo "Aggregation Repository schema created successfully."
