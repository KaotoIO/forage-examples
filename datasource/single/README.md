# Camel Forage Database Integration

This guide demonstrates how to use Camel Forage to run Camel Routes that interact with a PostgreSQL database.

## Prerequisites

- Apache Camel with Forage support
- PostgreSQL database
- Maven (for Spring Boot export)
- **Forage plugin** installed:
  ```bash
  camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.3-SNAPSHOT
  ```

## Quick Start

### 1. Start PostgreSQL Database

Launch PostgreSQL using Camel infrastructure:

```bash
camel infra run postgres
```

**Connection Details:**
- Host: `localhost`
- Port: `5432`
- Username: `test`
- Password: `test`
- JDBC URL: `jdbc:postgresql://localhost:5432/postgres`

### 2. Set Up Test Data

Create the sample table with test data:

```bash
./setup-db.sh
```

This creates the `bar` table and inserts sample rows.

### 3. Run the Integration

```bash
camel run route.camel.yaml application.properties
```

The forage plugin auto-discovers the required dependencies from the properties files, so no `--dep` flags are needed.

## DataSource Configuration

The integration automatically creates a single datasource named `dataSource` following Camel's naming conventions. This datasource is immediately available for use with Camel components, particularly the `sql` component, without additional configuration.

## Export

### Spring Boot

```bash
camel export route.camel.yaml application.properties \
  --runtime=spring-boot \
  --gav=com.foo:acme:1.3-SNAPSHOT
```

```bash
mvn spring-boot:run
```

### Quarkus

```bash
camel export route.camel.yaml application.properties \
  --runtime=quarkus
```

```bash
mvn clean compile quarkus:dev
```

## Features

- **Single DataSource**: Simplified configuration with one primary database connection
- **Convention over Configuration**: Uses Camel's standard naming conventions
- **Spring Boot Ready**: Easy export to Spring Boot with built-in monitoring
- **Production Ready**: Includes connection pooling and metrics when using actuators
