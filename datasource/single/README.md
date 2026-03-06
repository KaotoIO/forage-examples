# Camel Forage Database Integration

This guide demonstrates how to use Camel Forage to run Camel Routes that interact with a PostgreSQL database.

## Prerequisites

- Apache Camel with Forage support
- PostgreSQL database
- Maven (for Spring Boot export)

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
camel run route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jdbc:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT
```

Or using the [Forage Camel JBang plugin](#using-the-forage-plugin):

```bash
camel forage run route.camel.yaml application.properties
```

## DataSource Configuration

The integration automatically creates a single datasource named `dataSource` following Camel's naming conventions. This datasource is immediately available for use with Camel components, particularly the `sql` component, without additional configuration.

## Export

### Spring Boot

```bash
camel export route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jdbc-starter:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT \
  --runtime=spring-boot \
  --gav=com.foo:acme:1.1-SNAPSHOT
```

```bash
mvn spring-boot:run
```

### Quarkus

```bash
camel export route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jdbc:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT \
  --runtime=quarkus
```

```bash
mvn clean compile quarkus:dev
```

## Using the Forage Plugin

The Forage Camel JBang plugin simplifies commands by automatically adding the required dependencies. Install it with:

```bash
camel plugin add forage \
  --command='forage' \
  --description='Forage Camel JBang Plugin' \
  --artifactId='camel-jbang-plugin-forage' \
  --groupId='io.kaoto.forage' \
  --version='1.1-SNAPSHOT' \
  --gav='io.kaoto.forage:camel-jbang-plugin-forage:1.1-SNAPSHOT'
```

Then use `camel forage run` and `camel forage export` instead of specifying `--dep` flags manually.

## Features

- **Single DataSource**: Simplified configuration with one primary database connection
- **Convention over Configuration**: Uses Camel's standard naming conventions
- **Spring Boot Ready**: Easy export to Spring Boot with built-in monitoring
- **Production Ready**: Includes connection pooling and metrics when using actuators
