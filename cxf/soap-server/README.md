# Camel Forage CXF SOAP Server Example

Expose a SOAP web service endpoint using a contract-first approach. Forage sets up the CXF server endpoint from a WSDL contract and properties, and your Camel route handles the business logic -- no Java annotations or service interfaces required.

This is useful when you need to stand up a SOAP facade in front of modern services, build a REST-to-SOAP bridge, or provide a SOAP interface for legacy clients that cannot migrate to REST.

## Prerequisites

- **Camel JBang** with the Forage plugin installed:
  ```bash
  camel plugin add -g=io.kaoto.forage -a=camel-jbang-plugin-forage -v=1.6-SNAPSHOT
  ```

## Configuration

The server uses a contract-first approach with a WSDL file (`hello.wsdl`) that defines the service contract:

```properties
# Server endpoint
forage.helloServer.cxf.address=http://localhost:8080/services/hello
forage.helloServer.cxf.wsdl.url=file:hello.wsdl
forage.helloServer.cxf.service.name={http://example.com/hello}HelloService
forage.helloServer.cxf.port.name={http://example.com/hello}HelloPort
forage.helloServer.cxf.data.format=PAYLOAD
forage.helloServer.cxf.logging.enabled=true

# Client endpoint (used by the test caller route)
forage.helloClient.cxf.address=http://localhost:8080/services/hello
forage.helloClient.cxf.wsdl.url=file:hello.wsdl
forage.helloClient.cxf.service.name={http://example.com/hello}HelloService
forage.helloClient.cxf.port.name={http://example.com/hello}HelloPort
forage.helloClient.cxf.data.format=PAYLOAD
```

Using `PAYLOAD` data format means you work with raw XML -- no need for JAX-WS service endpoint interfaces or `@WebService` annotations. The WSDL file defines the service contract, and Forage creates the `CxfEndpoint` from it.

## What Happens

1. Forage creates two CXF endpoints: `helloServer` (server) and `helloClient` (client) in the Camel registry
2. The server route listens for SOAP requests at `http://localhost:8080/services/hello`
3. Incoming SOAP messages are logged and a response is returned
4. A built-in test caller uses `cxf:bean:helloClient` to send a SOAP request and verify the server works

## Running the Example

```bash
camel run *
```

You should see:

```text
Server received SOAP request
Server sending SOAP response
Test caller received response: <sayHelloResponse ...>Hello from CXF server</sayHelloResponse>
```

You can also test with curl:

```bash
curl -X POST http://localhost:8080/services/hello \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <sayHello xmlns="http://example.com/hello"><name>World</name></sayHello>
        </soap:Body>
      </soap:Envelope>'
```

## Features Demonstrated

- [x] Contract-first SOAP server with WSDL
- [x] PAYLOAD data format -- raw XML, no JAX-WS annotations required
- [x] CXF message logging for debugging
- [x] Built-in test caller route for self-verification
- [x] Zero Java code -- WSDL + properties + YAML only

## Export

```bash
# Spring Boot
camel export route.camel.yaml application.properties hello.wsdl \
  --runtime=spring-boot \
  --gav=com.example:cxf-soap-server:1.0-SNAPSHOT \
  --directory=/tmp/cxf-server-spring-boot

cd /tmp/cxf-server-spring-boot && mvn spring-boot:run

# Quarkus
camel export route.camel.yaml application.properties hello.wsdl \
  --runtime=quarkus \
  --gav=com.example:cxf-soap-server:1.0-SNAPSHOT \
  --directory=/tmp/cxf-server-quarkus

cd /tmp/cxf-server-quarkus && mvn clean compile quarkus:dev
```

> **Note:** When exporting to Quarkus, you may need to adjust the CXF address to a relative path (e.g., `/services/hello`) because Quarkus manages the HTTP server.
