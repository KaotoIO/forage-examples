#!/bin/bash

echo "Starting Camel Forage Shiro Security Policy Example"
echo "===================================================="
echo ""
echo "Endpoints:"
echo "  Public:  http://localhost:8080/api/public"
echo "  Secure:  http://localhost:8080/api/secure"
echo ""
echo "Test commands:"
echo "  curl http://localhost:8080/api/public"
echo "  curl -H 'X-Username: admin' -H 'X-Password: secret' http://localhost:8080/api/secure"
echo ""

camel run Route.java shiro.ini application.properties
