# Camel Forage InfluxDB 2 Example

Configure an InfluxDB 2 client using Forage properties, then write a fixed point
from a Camel YAML route. Forage creates and manages the client bean.

## Prerequisites

Install the tools and Forage plugin listed in the [parent README](../README.md).
Run the following commands from this directory, using the same terminal for
setup and running Camel so the environment variables remain available.

## Start InfluxDB 2

Start a disposable local database. The image initializes the `writer` user,
the `acme` organization, the `metrics` bucket, and an admin token.
The credentials below are only for this local example.

```bash
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}
export FORAGE_INFLUXDB2_TOKEN=forage-test-token

${CONTAINER_RUNTIME} run --rm -d --name forage-example-influxdb2 \
  -p 127.0.0.1:28086:8086 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=writer \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=test-password \
  -e DOCKER_INFLUXDB_INIT_ORG=acme \
  -e DOCKER_INFLUXDB_INIT_BUCKET=metrics \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN="${FORAGE_INFLUXDB2_TOKEN}" \
  docker.io/library/influxdb:2.7
```

Set `CONTAINER_RUNTIME=podman` before this block to use Podman.
Wait for initialization by repeating this request until it reports `"allowed": false`:

```bash
curl -fsS http://localhost:28086/api/v2/setup
```

## Configuration

The client configuration in `application.properties` is:

```properties
forage.influxdb2.url=http://localhost:28086
```

`FORAGE_INFLUXDB2_TOKEN` supplies `forage.influxdb2.token` through Forage's
environment configuration. Forage registers a `com.influxdb.client.InfluxDBClient`
named `influxdb2` in the Camel registry. The route uses that bean through:

```yaml
- to:
    uri: influxdb2:influxdb2
    parameters:
      org: acme
      bucket: metrics
      autoCreateOrg: false
      autoCreateBucket: false
```

The first `influxdb2` selects the Camel component; the second is the Forage bean
name. The organization and bucket are Camel endpoint options. Forage configures
the URL and token. This route uses the existing organization and bucket created
during database setup.

Camel looks up the organization and bucket when starting the endpoint, so the
token must allow those lookups as well as writes. The local example's admin token
also permits the verification query.

For real deployments, use a scoped token limited to these lookups and writes to
the target bucket; add read access if you also need to query data.

## What Happens

1. Forage creates the client from the properties and environment variable.
2. A timer fires once. A short Groovy expression builds a `temperature` point
   with the numeric field `value=21` and tags `sensor=demo` and `room=office`.
3. The tags are labels that identify the sample and can be used to filter queries.
4. The route submits the point through the Forage client and logs the send.

The expression only builds the sample point; Forage supplies the client. Camel
JBang automatically resolves the Groovy language used by the YAML route.

## Run the Example

```bash
camel run route.camel.yaml application.properties
```

Expected log message:

```text
InfluxDB 2 point sent: temperature, sensor=demo, room=office, value=21
```

Camel remains running after the single timer event. Writes are asynchronous:
leave Camel running and allow a few seconds for the point to appear in the query.
Each new run writes another point with a new timestamp.

## Verify the Point

In another terminal, set the example token and query InfluxDB with Flux:

```bash
export FORAGE_INFLUXDB2_TOKEN=forage-test-token
curl -fsS 'http://localhost:28086/api/v2/query?org=acme' \
  -H "Authorization: Token ${FORAGE_INFLUXDB2_TOKEN}" \
  -H 'Content-Type: application/vnd.flux' \
  -H 'Accept: application/csv' \
  --data 'from(bucket:"metrics")
    |> range(start:-1h)
    |> filter(fn:(r) => r._measurement == "temperature" and r._field == "value")
    |> filter(fn:(r) => r.sensor == "demo" and r.room == "office")
    |> last()'
```

The CSV response contains a row with `_measurement` equal to `temperature`,
`_field` equal to `value`, and `_value` equal to `21`. The `sensor` and `room`
columns contain the tags `demo` and `office`.

## Cleanup

Stop Camel with Ctrl+C, then run these commands in the setup terminal:

```bash
${CONTAINER_RUNTIME} stop forage-example-influxdb2
unset FORAGE_INFLUXDB2_TOKEN
```

The container was started with `--rm`, so stopping it removes its disposable data.
