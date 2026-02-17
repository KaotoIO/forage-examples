# Camel Forage JMS Single Connection Factory Example

This example demonstrates how to use Camel Forage to automatically configure a JMS ConnectionFactory with ActiveMQ Artemis.

## Prerequisites

1. **ActiveMQ Artemis** running on `localhost:61616`
  ```bash
  camel infra run artemis
  ```

  or ```bash
   # Using Docker
   docker run -it --rm \
     -p 61616:61616 \
     -p 8161:8161 \
     -e ARTEMIS_USERNAME=admin \
     -e ARTEMIS_PASSWORD=admin \
     apache/activemq-artemis:latest
   ```

   Or download and run standalone: https://activemq.apache.org/components/artemis/download/

## Configuration

The `forage-connectionfactory.properties` file configures the JMS connection:

- **JMS Kind**: `artemis` - Uses ActiveMQ Artemis provider
- **Broker URL**: `tcp://localhost:61616` - Connection to Artemis broker
- **Credentials**: Username/password for authentication
- **Connection Pool**: Configured with pooled-jms for optimal performance

## What Happens

1. **Automatic ConnectionFactory Creation**: Camel Forage automatically creates and configures a pooled JMS ConnectionFactory named `connectionFactory` in the Camel registry
2. **Timer Producer**: Sends a message every 5 seconds to the `test.queue`
3. **JMS Consumer**: Receives and logs messages from `test.queue`

## Running the Example

### Using Camel JBang (Java DSL)

```bash
camel run Route.java application.properties \
  --dep=io.kaoto.forage:forage-jms-artemis:1.0-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jms:1.0-SNAPSHOT
```

### Using Camel JBang (YAML DSL)

```bash
camel run route.camel.yaml application.properties \
  --dep=io.kaoto.forage:forage-jms-artemis:1.0-SNAPSHOT \
  --dep=io.kaoto.forage:forage-jms:1.0-SNAPSHOT
```

## Features Demonstrated

- ✅ Automatic JMS ConnectionFactory configuration via properties
- ✅ Connection pooling with pooled-jms
- ✅ Producer/Consumer pattern
- ✅ Zero boilerplate - no manual ConnectionFactory setup needed

## Transaction Support (Optional)

To enable XA transactions, update `forage-connectionfactory.properties`:

```properties
jms.transaction.enabled=true
jms.transaction.timeout.seconds=30
```

When transactions are enabled, Camel Forage will:
- Create an XAConnectionFactory
- Initialize Narayana transaction manager
- Register JTA transaction policies in the Camel registry

## Multiple Connection Factories

To configure multiple connection factories, use prefixes:

```properties
# First connection factory
broker1.jms.kind=artemis
broker1.jms.broker.url=tcp://localhost:61616

# Second connection factory
broker2.jms.kind=artemis
broker2.jms.broker.url=tcp://localhost:61617
```

Then reference by name:
```java
from("timer:test")
    .to("jms:queue:test?connectionFactory=#broker1");
```

## Supported JMS Providers

- **ActiveMQ Artemis** (`jms.kind=artemis`)
- **IBM MQ** (`jms.kind=ibmmq`)

Add the corresponding dependency for your provider.
