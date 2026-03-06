# Camel JDBC Idempotent Repository Example

This example demonstrates how to use Apache Camel's JDBC-based idempotent repository with Camel Forage to prevent duplicate message processing.

## Overview

The integration monitors the `data/inbox` directory for files and uses a PostgreSQL-backed idempotent repository to track processed files by name. Files with the same name are only processed once, preventing duplicate processing.

## Architecture

- **Route**: File consumer that polls `data/inbox` directory
- **Idempotent Consumer**: Uses `CamelFileName` header as the unique key
- **Repository**: JDBC-based idempotent repository (`#camel_idempotent`) stored in PostgreSQL table `camel_idempotent`
- **Data Source**: Configured via Camel Forage JDBC with connection pooling

## Prerequisites

- Apache Camel CLI installed
- PostgreSQL accessible (default: localhost:5432)
- Camel Forage JDBC dependencies available

## Configuration

The `forage-datasource-factory.properties` file configures:

- **Database**: PostgreSQL connection (jdbc:postgresql://localhost:5432/postgres)
- **Credentials**: username=test, password=test
- **Idempotent Repository**: Enabled with table name `camel_idempotent`
- **Transactions**: Enabled with 30-second timeout

## Running the Example

1. **Start PostgreSQL**:
   ```bash
   camel infra run postgres
   ```

2. **Run the integration**:
   ```bash
   camel run jdbc-idempotent.camel.yaml application.properties \
     --dep=io.kaoto.forage:forage-jdbc:1.1-SNAPSHOT \
     --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT
   ```

3. **Test idempotency**:
   - Copy `test.txt` into `data/inbox` → File is processed (logged and deleted)
   - Copy `test.txt` again into `data/inbox` → File is **not** processed (idempotent filter blocks it)
   - Copy a file with a different name → File is processed (new unique key)

## Expected Behavior

On first run with a file:
```
Discovered file: test.txt (size: XXX bytes)
Processed file: test.txt with content: ...
```

On duplicate file (same name):
```
Discovered file: test.txt (size: XXX bytes)
```
(Processing is skipped - no "Processed file" log appears)
