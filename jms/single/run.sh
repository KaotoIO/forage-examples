#!/bin/bash

echo "Starting Camel Forage JMS Example with ActiveMQ Artemis"
echo "========================================================"
echo ""
echo "Prerequisites:"
echo "- ActiveMQ Artemis should be running on tcp://localhost:61616"
echo "- Start Artemis with: camel infra run artemis"
echo ""

camel run route.camel.yaml --dep=io.kaoto.forage:forage-jms-artemis:1.0-SNAPSHOT --dep=io.kaoto.forage:forage-jms:1.0-SNAPSHOT
