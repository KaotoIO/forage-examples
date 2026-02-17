#!/bin/bash
# Setup database schema for the Event Booking example
# Requires: PostgreSQL running on localhost:5432 (start with: camel infra run postgres)

set -e

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-test}"
PGPASSWORD="${PGPASSWORD:-test}"
PGDATABASE="${PGDATABASE:-postgres}"

export PGPASSWORD

echo "Creating Event Booking schema on ${PGHOST}:${PGPORT}/${PGDATABASE}..."

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<'SQL'
-- Create the events table to store event information
CREATE TABLE IF NOT EXISTS events (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    available_seats INT NOT NULL CHECK (available_seats >= 0)
);

-- Create the bookings table to link users to events
CREATE TABLE IF NOT EXISTS bookings (
    booking_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES events(event_id),
    user_id INT NOT NULL,
    booking_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add an index for faster lookups
CREATE INDEX IF NOT EXISTS idx_bookings_event_id ON bookings(event_id);

-- Reset and insert sample data with predictable IDs
-- The booking JSON files reference event_id 1 and 2
TRUNCATE bookings, events RESTART IDENTITY CASCADE;

INSERT INTO events (name, available_seats) VALUES ('Camel Development Conference', 150);
INSERT INTO events (name, available_seats) VALUES ('Advanced Messaging Workshop', 1);
SQL

echo "Event Booking schema created successfully."
