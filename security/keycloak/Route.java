// camel-k: dependency=mvn:io.kaoto.forage:forage-security-keycloak:1.3-SNAPSHOT
// camel-k: dependency=mvn:io.kaoto.forage:forage-core-security:1.3-SNAPSHOT
// camel-k: dependency=mvn:io.kaoto.forage:forage-core-common:1.3-SNAPSHOT
// camel-k: dependency=mvn:org.apache.camel:camel-keycloak
package com.foo.acme;

import org.apache.camel.CamelAuthorizationException;
import org.apache.camel.Exchange;
import org.apache.camel.builder.RouteBuilder;

import io.kaoto.forage.core.security.SecurityPolicyProvider;

public class Route extends RouteBuilder {

    @Override
    public void configure() throws Exception {

        SecurityPolicyProvider provider = findKeycloakProvider();
        getContext().getRegistry().bind("keycloakPolicy", provider.create(null));

        onException(CamelAuthorizationException.class)
                .handled(true)
                .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(401))
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("Unauthorized - invalid or missing Keycloak token"));

        from("platform-http:/api/secure")
                .policy("keycloakPolicy")
                .log("Authenticated user accessing secure endpoint - token validated by Keycloak")
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("Access granted - Keycloak token is valid and role requirements met"))
                .end();

        from("platform-http:/api/public")
                .log("Public endpoint accessed - no authentication required")
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("This is a public endpoint"));
    }

    private SecurityPolicyProvider findKeycloakProvider() {
        for (SecurityPolicyProvider p : java.util.ServiceLoader.load(SecurityPolicyProvider.class)) {
            if ("keycloak".equals(p.name())) {
                return p;
            }
        }
        throw new IllegalStateException("Keycloak SecurityPolicyProvider not found on classpath");
    }
}
