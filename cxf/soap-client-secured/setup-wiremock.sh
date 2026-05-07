#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/certs"
STUBS_DIR="$SCRIPT_DIR/wiremock"
WIREMOCK_PORT="${WIREMOCK_PORT:-8443}"

echo "=== Generating self-signed certificates ==="
mkdir -p "$CERTS_DIR"

# Generate server keystore with self-signed certificate
keytool -genkeypair -alias wiremock -keyalg RSA -keysize 2048 \
  -keystore "$CERTS_DIR/wiremock-keystore.jks" -storepass changeit -keypass changeit \
  -dname "CN=localhost,OU=Test,O=Forage,L=Test,ST=Test,C=US" \
  -validity 365 -storetype JKS 2>/dev/null

# Export certificate
keytool -exportcert -alias wiremock \
  -keystore "$CERTS_DIR/wiremock-keystore.jks" -storepass changeit \
  -file "$CERTS_DIR/wiremock.crt" 2>/dev/null

# Create truststore for the Camel client
keytool -importcert -alias wiremock -file "$CERTS_DIR/wiremock.crt" \
  -keystore "$CERTS_DIR/truststore.jks" -storepass changeit \
  -noprompt -storetype JKS 2>/dev/null

echo "Certificates created in $CERTS_DIR"

echo ""
echo "=== Starting WireMock with HTTPS on port $WIREMOCK_PORT ==="
docker run -d --name forage-wiremock-https \
  -p "$WIREMOCK_PORT:8443" \
  -v "$CERTS_DIR/wiremock-keystore.jks:/certs/keystore.jks:ro" \
  -v "$STUBS_DIR:/home/wiremock:ro" \
  wiremock/wiremock:latest \
  --https-port 8443 \
  --https-keystore /certs/keystore.jks \
  --keystore-password changeit \
  --key-manager-password changeit \
  --verbose

echo ""
echo "Waiting for WireMock to start..."
for i in $(seq 1 15); do
  if curl -sk "https://localhost:$WIREMOCK_PORT/__admin" >/dev/null 2>&1; then
    echo "WireMock is ready at https://localhost:$WIREMOCK_PORT"
    echo ""
    echo "Test with:"
    echo "  curl -sk https://localhost:$WIREMOCK_PORT/ws/hello?wsdl"
    echo ""
    echo "Run the secured client:"
    echo "  camel run *"
    echo ""
    echo "Stop with:"
    echo "  docker rm -f forage-wiremock-https"
    exit 0
  fi
  sleep 1
done

echo "ERROR: WireMock did not start within 15 seconds"
docker logs forage-wiremock-https
exit 1
