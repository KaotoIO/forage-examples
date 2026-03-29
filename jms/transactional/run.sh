#!/bin/bash

echo "Starting Camel Forage JMS Transactional Example"
echo "==============================================="
echo ""
echo "Prerequisites:"
echo "- ActiveMQ Artemis should be running on tcp://localhost:61616"
echo "- Start Artemis with: camel infra run artemis"
echo ""
echo "This example demonstrates:"
echo "- XA transactions with Narayana transaction manager"
echo "- Automatic rollback on errors"
echo "- Message redelivery"
echo "- Dead Letter Queue handling"
echo ""

camel run route.camel.yaml
