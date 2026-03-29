# Camel Forage Distributed XA Transactions Example

This example demonstrates **distributed XA transactions** spanning both JMS (ActiveMQ Artemis) and JDBC (PostgreSQL) using Camel Forage with the Narayana transaction manager.

## What This Example Shows

This is a transaction demonstration scenario where:
1. Messages arrive via JMS queue with an event ID
2. Event data is inserted into PostgreSQL database
3. Message is forwarded to another JMS queue
4. Messages with body "ROLLBACK" trigger transaction rollback
5. **All operations happen in a single XA transaction** - if any step fails, everything rolls back

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    XA Transaction Boundary                   │
│                                                              │
│  JMS Consumer  →  DB Insert  →  JMS Producer  →  Decision   │
│  (queue: in)      (test table)  (queue: out)    (rollback?) │
│                                                              │
│  If ANY step fails, ALL operations are rolled back          │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Forage Plugin

Install the forage plugin:

```bash
camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.1-SNAPSHOT
```

### PostgreSQL

Start PostgreSQL with the test database:

```bash
camel infra run postgres
```

Then create the schema:

```bash
./setup-db.sh
```

### ActiveMQ Artemis

Start ActiveMQ Artemis:

```bash
# Using Camel JBang (recommended)
camel infra run artemis
```

## Configuration

### JDBC Configuration (`forage-datasource-factory.properties`)
```properties
forage.jdbc.db.kind=postgresql
forage.jdbc.transaction.enabled=true
forage.jdbc.transaction.node.id=xa-node1
```

### JMS Configuration (`forage-connectionfactory.properties`)
```properties
forage.jms.kind=artemis
forage.jms.transaction.enabled=true
forage.jms.transaction.node.id=xa-node1
```

**Important**: Both configurations share the same:
- `transaction.node.id`: Identifies this transaction manager instance
- `transaction.object.store.directory`: Shared transaction log directory

## Running the Example

### Using Camel JBang (YAML DSL)

```bash
camel run transaction.camel.yaml application.properties
```

The forage plugin auto-discovers the required dependencies from the properties files, so no `--dep` flags are needed.

## What Happens

### Route 1: Transaction Processing Route

This route consumes messages from the `in` queue and processes them within an XA transaction:

1. **JMS Consumer**: Receives message from `in` queue (transacted)
2. **Transaction Start**: Logs the message body and eventId header
3. **Database Insert**: Executes `INSERT INTO test (id, action) VALUES (eventId, 'test')`
4. **Query Success**: Logs successful database operation
5. **JMS Producer**: Sends message to `out` queue (transacted)
6. **Decision Point**:
   - If body is "ROLLBACK": throws exception → **transaction rolls back**
   - Otherwise: transaction commits successfully

### Route 2: Message Generator

A timer-based route that generates test messages every 5 seconds:

1. **Timer Trigger**: Fires every 5 seconds
2. **Generate EventId**: Creates random ID (0-10000)
3. **Random Decision**:
   - 40% chance: Sets body to "ROLLBACK" and sends to `in` queue
   - 60% chance: Sets body to "OK" and sends to `in` queue

### Successful Flow (Body = "OK")

1. Message consumed from `in` queue
2. Database insert executes
3. Message sent to `out` queue
4. **Transaction commits** - All operations persist

### Rollback Flow (Body = "ROLLBACK")

1. Message consumed from `in` queue
2. Database insert executes
3. Message sent to `out` queue
4. Exception thrown
5. **Transaction rolls back**:
   - Message returns to `in` queue
   - Database insert is undone
   - Message to `out` queue is cancelled
6. **Broker Redelivery**: Artemis automatically retriggers the route
7. **Retry Loop**: The message keeps failing and being redelivered
8. **Max Redeliveries Exhausted**: After the broker's maximum redelivery attempts
9. **Dead Letter Queue**: Broker automatically moves the message to DLQ

## Key Features Demonstrated

### Distributed XA Transactions
- Single transaction spanning JMS and JDBC
- Two-phase commit protocol ensures ACID properties
- Either all operations succeed or all fail

### Automatic Rollback and Redelivery
- JMS message consumption is rolled back
- Database insert is rolled back
- Message returns to queue for redelivery
- Broker automatically retriggers the route
- After max redeliveries exhausted, message moves to DLQ

### Transaction Recovery
- Narayana transaction manager logs all operations
- Can recover in-doubt transactions after crash
- Transaction logs stored in `tx-object-store/`

### Shared Transaction Context
- Same transaction manager instance across JMS and JDBC
- Coordinated by Narayana XA transaction manager
- Zero configuration - automatically wired by Camel Forage

## Observing Transactions

### Check Transaction Logs
```bash
ls -la tx-object-store/
```

You'll see transaction logs for both JMS and JDBC operations.

## Export

### Camel Spring Boot

The example can be exported to a Camel Spring Boot project via

```bash
camel export transaction.camel.yaml forage-connectionfactory.properties forage-datasource-factory.properties \
 --runtime=spring-boot --directory=spring-boot-export
```

### Monitor Artemis Console

The Artemis console is available at:
- Console URL: http://localhost:8161/console
- Queues URL: http://localhost:8161/console/artemis/artemisQueues?nid=root-org.apache.activemq.artemis-broker
- Username: `artemis`
- Password: `artemis`

You can follow the execution in real-time by watching the queues:
- `in`: Input queue for transaction processing
- `out`: Output queue for successfully processed messages
- `DLQ`: Dead Letter Queue for messages that failed max redelivery attempts

## Testing Scenarios

### Force Rollback
The example automatically triggers rollbacks for messages with body "ROLLBACK" (approximately 40% of messages based on the random condition). Watch the logs:

```
Start transaction with message ROLLBACK and event id 1234
Query executed successfully
[Exception thrown: Rollback transaction]
[Transaction rolls back]
[Broker redelivers message]
[Process repeats until max redeliveries]
[Message moved to DLQ]
```

Check the database - no records will be saved for ROLLBACK messages, even though the insert was executed before the rollback.

### Verify Atomicity
1. Stop the example mid-processing
2. Restart it
3. Check transaction recovery logs
4. Verify no partial data in database

## Transaction Policies

The example uses `PROPAGATION_REQUIRED`:
- Joins existing transaction if one exists
- Creates new transaction if none exists

Other available policies registered by Camel Forage:
- `PROPAGATION_REQUIRES_NEW`: Always create new transaction
- `PROPAGATION_MANDATORY`: Must have existing transaction
- `PROPAGATION_SUPPORTS`: Optional transaction
- `PROPAGATION_NOT_SUPPORTED`: Suspend transaction
- `PROPAGATION_NEVER`: Fail if transaction exists

## Advanced Configuration

### Configure Broker Redelivery Attempts
The redelivery policy is configured on the Artemis broker side. By default, Artemis will redeliver messages a certain number of times before moving them to the DLQ. To customize this behavior, configure the broker's address settings.

### Change Transaction Timeout
In both configuration files:
```properties
jdbc.transaction.timeout.seconds=60
jms.transaction.timeout.seconds=60
```

### Enable Additional Recovery
```properties
jdbc.transaction.enable.recovery=true
jms.transaction.enable.recovery=true
```

## Common Issues

### Transaction Timeout
If processing takes > 30 seconds, transaction times out. Increase timeout:
```properties
jdbc.transaction.timeout.seconds=60
jms.transaction.timeout.seconds=60
```

### Database Connection Issues
Ensure PostgreSQL is running and accessible.

### Transaction Log Corruption
Delete transaction logs and restart:
```bash
rm -rf tx-object-store/
```

## Use Cases

This pattern is essential for:
- **Order Processing**: Ensuring order consistency across systems
- **Financial Transactions**: Atomic money transfers across accounts
- **Inventory Management**: Coordinating stock updates with order placement
- **Billing Systems**: Ensuring invoice creation matches payment processing
- **Event Sourcing**: Maintaining event consistency across message and database

## Architecture Notes

### Why XA Transactions?

Without XA transactions, you could have:
- Message consumed but database insert fails → Lost data
- Database insert succeeds but message send fails → Incomplete processing
- Partial state across systems → Data inconsistency

With XA transactions:
- All-or-nothing guarantee
- No lost messages or orphaned data
- Consistent state across JMS and database

### Performance Considerations

XA transactions have overhead:
- Two-phase commit protocol
- Transaction log writes
- Coordination between resource managers

Use when data consistency is critical. For high-throughput scenarios with relaxed consistency requirements, consider eventual consistency patterns instead.
