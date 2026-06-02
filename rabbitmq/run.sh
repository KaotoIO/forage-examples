#!/bin/bash

echo "Starting Camel Forage Spring RabbitMQ Example"
echo "=============================================="
echo ""
echo "Prerequisites:"
echo "- RabbitMQ should be running on localhost:5672"
echo "- Start RabbitMQ with: camel infra run rabbitmq"
echo ""

camel run route.camel.yaml application.properties
