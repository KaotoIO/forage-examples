# Camel Forage Multi-Datasource Integration

This project demonstrates how to use Camel Forage to run Apache Camel routes that interact with multiple databases (MySQL and PostgreSQL).

## Prerequisites

- Docker (for running database containers)
- Apache Camel CLI
- Maven (for Spring Boot export)

## Database Setup

### MySQL Database

Start a MySQL container:

```bash
docker run -e MYSQL_ROOT_PASSWORD=pwd -p3306:3306 mysql:latest
```

**Connection Details:**
- Host: `localhost`
- Port: `3306`
- User: `root`
- Password: `pwd`
- JDBC URL: `jdbc:mysql://localhost:3306`

### PostgreSQL Database

Start a PostgreSQL container using Camel infrastructure:

```bash
camel infra run postgres
```

**Connection Details:**
- Host: `localhost`
- Port: `5432`
- User: `test`
- Password: `test`
- JDBC URL: `jdbc:postgresql://localhost:5432/postgres`

### Create Test Data

Once both databases are running, create the schemas and sample data:

```bash
./setup-db.sh
```

This creates the MySQL `test.foo` table and the PostgreSQL `bar` table with sample rows.

## Running the Integration

```bash
camel run route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jdbc:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-mysql:1.1-SNAPSHOT
```

Or using the [Forage Camel JBang plugin](#using-the-forage-plugin):

```bash
camel forage run route.camel.yaml application.properties
```

The integration creates two datasources (`ds1` and `ds2`) that can be referenced in Camel routes following Camel best practices.

### Export

Export the project to a Spring Boot or Quarkus application:

#### Spring Boot

```bash
camel export route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jdbc-starter:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-mysql:1.1-SNAPSHOT \
  --runtime=spring-boot \
  --gav=com.foo:acme:1.1-SNAPSHOT
```

```bash
mvn spring-boot:run
```

#### Quarkus

```bash
camel export route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jdbc:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-postgresql:1.1-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jdbc-mysql:1.1-SNAPSHOT \
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

- **Multiple Datasource Support**: Seamlessly work with MySQL and PostgreSQL databases
- **Spring Boot Integration**: Export to Spring Boot for production deployments
- **Monitoring**: When web and actuator dependencies are added, datasource and connection pool metrics are automatically exposed
- **Best Practices**: Follows Apache Camel conventions for datasource configuration and routing