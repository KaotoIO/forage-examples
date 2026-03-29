# Event Booking System with Apache Camel Forage

This example demonstrates a **transactional event booking system** using Apache Camel with the Forage datasource framework. The system ensures data consistency when booking event seats by implementing atomic transactions that prevent double-booking and maintain database integrity.

## Overview

The application handles event seat reservations through a file-based workflow:
- JSON booking requests are placed in the `data/inbox` folder
- Apache Camel routes process these files and execute database transactions
- Each booking atomically reduces available seats and creates a booking record
- Failed bookings (e.g., sold-out events) trigger transaction rollbacks

## Architecture

- **File Processing Route**: Monitors `data/inbox` for JSON booking files
- **Event Booking Route**: Handles transactional database operations
- **PostgreSQL Database**: Stores events and bookings with referential integrity
- **Forage Framework**: Provides datasource management and transaction support

## Prerequisites

- Java 17 or higher
- Maven 3.8+
- PostgreSQL database running on localhost:5432
- Apache Camel JBang
- **Forage plugin** installed:
  ```bash
  camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.1-SNAPSHOT
  ```

### 1. Create Database Schema

Run postgresql database with `camel infra run postgres`

Then create the schema and sample data:

```bash
./setup-db.sh
```

This creates the `events` and `bookings` tables and inserts sample event data.

## Running the Application

```bash
camel run book.camel.yaml application.properties
```

The forage plugin auto-discovers the required dependencies from the properties files, so no `--dep` flags are needed.

### Spring Boot Export

```bash
camel export book.camel.yaml application.properties \
  --runtime=spring-boot
```

```bash
mvn spring-boot:run
```

## Testing the Application

The project includes three sample booking files to demonstrate different scenarios:

### Test Case 1: Successful Booking
```bash
cp booking-1.json data/inbox/
```
- **File**: `booking-1.json` (Event ID: 1, User ID: 456)
- **Expected**: Successfully books a seat for "Camel Development Conference"
- **Result**: Available seats decrease from 150 to 149, booking record created

### Test Case 2: Last Available Seat
```bash
cp booking-2.json data/inbox/
```
- **File**: `booking-2.json` (Event ID: 2, User ID: 789)
- **Expected**: Successfully books the last seat for "Advanced Messaging Workshop"
- **Result**: Available seats decrease from 1 to 0, booking record created

### Test Case 3: Sold Out Event (Transaction Rollback)
```bash
cp booking-3.json data/inbox/
```
- **File**: `booking-3.json` (Event ID: 2, User ID: 999)
- **Expected**: Fails because event is sold out
- **Result**: Transaction rollback, no changes to database, error logged

## How the Transaction Flow Works

1. **File Detection**: The file monitoring route (`file-to-booking-route`) detects JSON files in `data/inbox`
2. **Transaction Start**: The booking route (`event-booking-route`) begins a database transaction
3. **Seat Reservation**: Attempts to update available seats with condition `WHERE available_seats > 0`
4. **Validation**: Checks if exactly one row was updated (seat successfully reserved)
5. **Booking Creation**: If successful, inserts a booking record
6. **Transaction Commit**: Both operations succeed and transaction commits
7. **Error Handling**: If seat unavailable, throws exception and rolls back transaction

## Key Features Demonstrated

- **ACID Transactions**: Ensures data consistency across multiple table operations
- **Optimistic Concurrency**: Uses conditional updates to prevent overselling
- **Error Handling**: Graceful handling of business logic failures
- **File Integration**: Event-driven processing with file system monitoring
- **Database Connection Pooling**: Efficient resource management