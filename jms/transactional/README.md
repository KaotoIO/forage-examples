# Camel Forage JMS Transactional Example

This example demonstrates how to use Camel Forage with XA transactions for reliable message processing using ActiveMQ Artemis and Narayana transaction manager.

## Prerequisites

**Forage plugin** installed:

```bash
camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.1-SNAPSHOT
```

ActiveMQ Artemis running on `localhost:61616`:

```bash
camel infra run artemis
```

Or with plain docker
```bash
docker run -it --rm \
  -p 61616:61616 \
  -p 8161:8161 \
  -e ARTEMIS_USERNAME=artemis \
  -e ARTEMIS_PASSWORD=artemis \
  apache/activemq-artemis:latest
```

Or use Camel JBang:
```bash
camel infra run artemis
```

## Configuration

The `forage-connectionfactory.properties` file enables XA transactions:

```properties
jms.transaction.enabled=true
jms.transaction.timeout.seconds=30
jms.transaction.enable.recovery=true
```

When transactions are enabled, Camel Forage will:
1. Create an `XAConnectionFactory` instead of a regular `ConnectionFactory`
2. Initialize the Narayana transaction manager
3. Register JTA transaction policies (PROPAGATION_REQUIRED, PROPAGATION_REQUIRES_NEW, etc.)
4. Enable transaction recovery mechanisms

## What Happens

### Normal Flow (70% of messages)
1. **Producer**: Sends a message to `input.queue` every 10 seconds
2. **Transactional Consumer**:
   - Begins XA transaction
   - Processes the message
   - Forwards to `output.queue`
   - Commits transaction
3. **Output Consumer**: Receives successfully processed messages

### Error Flow (30% of messages - simulated)
1. **Producer**: Sends a message to `input.queue`
2. **Transactional Consumer**:
   - Begins XA transaction
   - Simulates processing error
   - Rolls back transaction
   - Message returns to `input.queue`
3. **Redelivery**: Artemis automatically redelivers the message
4. **Dead Letter Queue**: After max redeliveries, message goes to DLQ

## Running the Example

### Using Camel JBang (Java DSL)

```bash
camel run Route.java application.properties
```

### Using Camel JBang (YAML DSL)

```bash
camel run route.camel.yaml application.properties
```

The forage plugin auto-discovers the required dependencies from the properties files, so no `--dep` flags are needed.

Or simply:
```bash
./run.sh
```

## Features Demonstrated

- ✅ **XA Transactions**: Full ACID guarantees across JMS operations
- ✅ **Automatic Rollback**: Failed processing automatically rolls back the transaction
- ✅ **Message Redelivery**: Artemis automatically redelivers rolled-back messages
- ✅ **Dead Letter Queue**: Messages that fail repeatedly go to DLQ
- ✅ **Transaction Recovery**: Narayana ensures transaction durability
- ✅ **Zero Configuration**: Transaction manager automatically configured

## Transaction Policies

When transactions are enabled, Camel Forage registers these policies in the registry:

| Policy | Behavior |
|--------|----------|
| `PROPAGATION_REQUIRED` | Join existing transaction or create new |
| `PROPAGATION_REQUIRES_NEW` | Always create new transaction |
| `PROPAGATION_MANDATORY` | Must have existing transaction |
| `PROPAGATION_SUPPORTS` | Join transaction if exists |
| `PROPAGATION_NOT_SUPPORTED` | Suspend transaction |
| `PROPAGATION_NEVER` | Fail if transaction exists |

Use them in routes:
```java
.transacted("PROPAGATION_REQUIRED")
```

## Observing Transactions

### Check Transaction Object Store
The transaction logs are stored in the `tx-object-store` directory:
```bash
ls -la tx-object-store/
```

### Monitor Artemis Web Console
Access at http://localhost:8161/console
- Username: `artemis`
- Password: `artemis`

Watch:
- Queue depths
- Message counts
- Redelivery attempts
- DLQ messages

## Advanced Configuration

### Custom Transaction Timeout
```properties
jms.transaction.timeout.seconds=60
```

### Volatile Object Store (for testing)
```properties
jms.transaction.object.store.type=volatile
```

### Multiple Transaction Nodes
```properties
jms.transaction.node.id=node1
```

## Use Cases

This pattern is essential for:
- **Financial transactions**: Ensuring message processing integrity
- **Order processing**: Preventing duplicate orders or lost messages
- **Event sourcing**: Guaranteeing event ordering and delivery
- **Distributed systems**: Coordinating across multiple resources (JMS + Database)
