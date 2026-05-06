#!/bin/bash

echo "Starting Camel Forage Keycloak Security Policy Example"
echo "======================================================="
echo ""
echo "Prerequisites:"
echo "- Keycloak should be running on http://localhost:8180"
echo "- Realm 'forage-demo' should be configured with client 'forage-app'"
echo ""
echo "Endpoints:"
echo "  Public:  http://localhost:8080/api/public"
echo "  Secure:  http://localhost:8080/api/secure"
echo ""
echo "Test commands:"
echo "  curl http://localhost:8080/api/public"
echo "  curl -H 'Authorization: Bearer <token>' http://localhost:8080/api/secure"
echo ""

camel run Route.java application.properties
