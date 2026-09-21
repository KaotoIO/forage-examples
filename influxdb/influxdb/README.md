# Camel Forage InfluxDB 1 Example

Configure an InfluxDB 1 client using Forage properties, then write a fixed point
from a Camel YAML route. Forage creates and manages the client bean.

## Prerequisites

Install the tools and Forage plugin listed in the [parent README](../README.md).
Run the following commands from this directory, using the same terminal for
setup and running Camel so the environment variables remain available.

## Start InfluxDB 1

Start a disposable local database with authentication enabled. The image creates
the `writer` admin user, the `metrics` database, and its `autogen` retention policy.
The credentials below are only for this local example.

```bash
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}
export FORAGE_INFLUXDB_PASSWORD=test-password

${CONTAINER_RUNTIME} run --rm -d --name forage-example-influxdb \
  -p 127.0.0.1:18086:8086 \
  -e INFLUXDB_DB=metrics \
  -e INFLUXDB_ADMIN_USER=writer \
  -e INFLUXDB_ADMIN_PASSWORD="${FORAGE_INFLUXDB_PASSWORD}" \
  -e INFLUXDB_HTTP_AUTH_ENABLED=true \
  docker.io/library/influxdb:1.8.10
```

Set `CONTAINER_RUNTIME=podman` before this block to use Podman.
Wait for initialization by repeating this query until the response lists `metrics`:

```bash
curl -fsS -u "writer:${FORAGE_INFLUXDB_PASSWORD}" -G \
  http://localhost:18086/query \
  --data-urlencode 'q=SHOW DATABASES'
```

## Configuration

The client configuration in `application.properties` is:

```properties
forage.influxdb.url=http://localhost:18086
forage.influxdb.username=writer
```

`FORAGE_INFLUXDB_PASSWORD` supplies `forage.influxdb.password` through Forage's
environment configuration. Forage registers an `org.influxdb.InfluxDB` client
named `influxdb` in the Camel registry. The route uses that bean through:

```yaml
- to:
    uri: influxdb:influxdb
    parameters:
      databaseName: metrics
      retentionPolicy: autogen
```

The first `influxdb` selects the Camel component; the second is the Forage bean
name. The database and retention policy are Camel endpoint options and must
already exist. Forage configures the connection and authentication.

## What Happens

1. Forage creates the client from the properties and environment variable.
2. A timer fires once. A short Groovy expression builds a `temperature` point
   with the numeric field `value=21` and tags `sensor=demo` and `room=office`.
3. The tags are labels that identify the sample and can be used to filter queries.
4. The route writes the point through the Forage client and logs the send.

The expression only builds the sample point; Forage supplies the client. Camel
JBang automatically resolves the Groovy language used by the YAML route.

## Run the Example

```bash
camel run route.camel.yaml application.properties
```

Expected log message:

```text
InfluxDB 1 point sent: temperature, sensor=demo, room=office, value=21
```

Camel remains running after the single timer event. Each new run writes another
point with a new timestamp.

## Verify the Point

In another terminal, set the example password and query InfluxDB with InfluxQL:

```bash
export FORAGE_INFLUXDB_PASSWORD=test-password
curl -fsS -u "writer:${FORAGE_INFLUXDB_PASSWORD}" -G \
  http://localhost:18086/query \
  --data-urlencode 'db=metrics' \
  --data-urlencode "q=SELECT value, sensor, room FROM temperature WHERE sensor = 'demo' AND room = 'office' ORDER BY time DESC LIMIT 1"
```

The JSON response contains a `temperature` series with columns `time`, `value`,
`sensor`, and `room`. Its row has value `21` and tags `demo` and `office`.

## Cleanup

Stop Camel with Ctrl+C, then run these commands in the setup terminal:

```bash
${CONTAINER_RUNTIME} stop forage-example-influxdb
unset FORAGE_INFLUXDB_PASSWORD
```

The container was started with `--rm`, so stopping it removes its disposable data.
