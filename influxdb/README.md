# Camel Forage InfluxDB Examples

Configure an InfluxDB client with Forage properties and use it from a Camel YAML
route. Each example writes one fixed `temperature` point with a `value` of `21`
and the labels `sensor=demo` and `room=office`, stored as InfluxDB tags. A query
filters by these tags to verify that the point was stored.

| Example | Authentication | Camel endpoint | Local port |
|---------|----------------|----------------|------------|
| [InfluxDB 1](influxdb/) | Username and password | `influxdb:influxdb` | `18086` |
| [InfluxDB 2](influxdb2/) | API token | `influxdb2:influxdb2` | `28086` |

Both examples contain `application.properties`, `route.camel.yaml`, and a README
with database setup, configuration, execution, verification, and cleanup steps.

## Prerequisites

- Java 17 or later
- [Camel JBang](https://camel.apache.org/manual/camel-jbang.html) 4.22.0
- Docker or Podman
- `curl`
- The Forage plugin with InfluxDB support, available in `1.6.1-SNAPSHOT`:

  ```bash
  camel plugin add forage \
    --gav=io.kaoto.forage:camel-jbang-plugin-forage:1.6.1-SNAPSHOT \
    --repos=https://central.sonatype.com/repository/maven-snapshots/
  ```

  Verify the installed plugin with `camel plugin get`.

Each properties file includes the snapshot repository so Camel can resolve the
Forage factories. The plugin discovers the required dependencies automatically
from the configuration; the run commands need no `--dep` flags.

## Choose an Example

From the repository root, enter `influxdb/influxdb` or `influxdb/influxdb2` and
follow that example's README.

The examples use different container names and ports, so they can run together.
Their credentials are for disposable local databases. The containers bind HTTP
to loopback; use HTTPS and your own credentials for remote deployments.
