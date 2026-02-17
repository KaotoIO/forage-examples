#!/bin/bash
# Setup database schema for the Multi-Datasource example
# Requires:
#   - PostgreSQL running on localhost:5432 (start with: camel infra run postgres)
#   - MySQL running on localhost:3306 (start with: docker run -e MYSQL_ROOT_PASSWORD=pwd -p3306:3306 mysql:latest)

set -e

# --- PostgreSQL setup ---
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-test}"
PGPASSWORD="${PGPASSWORD:-test}"
PGDATABASE="${PGDATABASE:-postgres}"

export PGPASSWORD

echo "Creating PostgreSQL table on ${PGHOST}:${PGPORT}/${PGDATABASE}..."

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<'SQL'
CREATE TABLE IF NOT EXISTS bar (
    id INTEGER PRIMARY KEY,
    content VARCHAR
);

INSERT INTO bar VALUES (1, 'postgres 1') ON CONFLICT (id) DO NOTHING;
INSERT INTO bar VALUES (2, 'postgres 2') ON CONFLICT (id) DO NOTHING;
SQL

echo "PostgreSQL table created successfully."

# --- MySQL setup ---
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-pwd}"

echo "Creating MySQL database and table on ${MYSQL_HOST}:${MYSQL_PORT}..."

mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" <<'SQL'
CREATE DATABASE IF NOT EXISTS test;
CREATE TABLE IF NOT EXISTS test.foo (
    id INTEGER PRIMARY KEY,
    content VARCHAR(255)
);

INSERT IGNORE INTO test.foo VALUES (1, 'mysql 1');
INSERT IGNORE INTO test.foo VALUES (2, 'mysql 2');
SQL

echo "MySQL database and table created successfully."
