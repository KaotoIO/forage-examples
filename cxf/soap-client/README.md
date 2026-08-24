# Camel Forage CXF SOAP Client Example

Call an existing SOAP web service from a Camel route with zero Java code. Forage auto-configures the CXF endpoint from a WSDL, handling service binding, message logging, and connection setup -- all from a properties file.

This is a common enterprise scenario: you have a legacy SOAP service (SAP, ERP, payment gateway) and need to integrate it into a modern Camel pipeline without writing boilerplate CXF configuration code.

## Prerequisites

- **Camel JBang** with the Forage plugin installed:
  ```bash
  camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.6-SNAPSHOT
  ```
- **A running SOAP service** to call. You can use the companion [SOAP Server example](../soap-server/) as the target:
  ```bash
  cd ../soap-server && camel run *
  ```

## Configuration

The `application.properties` file maps directly to the WSDL structure of the target service:

```properties
# Service endpoint address
forage.cxf.address=http://localhost:8080/services/hello

# WSDL location for service metadata discovery
forage.cxf.wsdl.url=http://localhost:8080/services/hello?wsdl

# Service and port names (from the WSDL <service> and <port> elements)
forage.cxf.service.name={http://example.com/hello}HelloService
forage.cxf.port.name={http://example.com/hello}HelloPort

# Data format: PAYLOAD sends/receives raw XML elements
forage.cxf.data.format=PAYLOAD

# Enable CXF message logging for request/response tracing
forage.cxf.logging.enabled=true
```

Forage reads these properties and creates a fully configured `CxfEndpoint` bean registered as `cxfEndpoint` in the Camel registry.

## What Happens

1. Forage creates a CXF SOAP endpoint from the properties and binds it as `cxfEndpoint` in the Camel registry
2. The route fires once, constructs a SOAP XML body, and sends it to `cxf:bean:cxfEndpoint`
3. CXF handles WSDL binding, SOAP envelope wrapping, and HTTP transport
4. The SOAP response is logged

## Running the Example

First, start the SOAP server (in a separate terminal):

```bash
cd ../soap-server && camel run *
```

Then run the client:

```bash
camel run *
```

You should see:

```text
SOAP response: <sayHelloResponse xmlns="http://example.com/hello"><greeting>Hello from CXF server</greeting></sayHelloResponse>
```

## Features Demonstrated

- [x] WSDL-driven CXF endpoint auto-configuration
- [x] SOAP operation dispatching via headers
- [x] CXF message logging (request/response tracing)
- [x] PAYLOAD data format for raw XML handling
- [x] Zero Java code -- properties + YAML only

## Export

Export to Spring Boot or Quarkus:

```bash
# Spring Boot
camel export route.camel.yaml application.properties \
  --runtime=spring-boot \
  --gav=com.example:cxf-soap-client:1.0-SNAPSHOT \
  --directory=/tmp/cxf-spring-boot

cd /tmp/cxf-spring-boot && mvn spring-boot:run

# Quarkus
camel export route.camel.yaml application.properties \
  --runtime=quarkus \
  --gav=com.example:cxf-soap-client:1.0-SNAPSHOT \
  --directory=/tmp/cxf-quarkus

cd /tmp/cxf-quarkus && mvn clean compile quarkus:dev
```

## Multiple SOAP Endpoints

To call multiple SOAP services, use named prefixes:

```properties
forage.payment.cxf.address=http://payment-svc:8080/ws/payment
forage.payment.cxf.data.format=PAYLOAD

forage.inventory.cxf.address=http://inventory-svc:8080/ws/stock
forage.inventory.cxf.data.format=PAYLOAD
```

Each prefix becomes a bean name. Reference them in routes:

```yaml
- to:
    uri: cxf:bean:payment
- to:
    uri: cxf:bean:inventory
```
