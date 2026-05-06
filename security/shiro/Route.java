// camel-k: dependency=mvn:io.kaoto.forage:forage-security-shiro:1.3-SNAPSHOT
// camel-k: dependency=mvn:io.kaoto.forage:forage-core-security:1.3-SNAPSHOT
// camel-k: dependency=mvn:io.kaoto.forage:forage-core-common:1.3-SNAPSHOT
// camel-k: dependency=mvn:org.apache.camel:camel-shiro
package com.foo.acme;

import org.apache.camel.CamelAuthorizationException;
import org.apache.camel.Exchange;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.shiro.security.ShiroSecurityConstants;
import org.apache.camel.component.shiro.security.ShiroSecurityToken;

import io.kaoto.forage.core.security.SecurityPolicyProvider;

public class Route extends RouteBuilder {

    @Override
    public void configure() throws Exception {

        SecurityPolicyProvider provider = findShiroProvider();
        getContext().getRegistry().bind("shiroPolicy", provider.create(null));

        onException(CamelAuthorizationException.class)
                .handled(true)
                .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(403))
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("Access denied - insufficient permissions"));

        onException(org.apache.camel.NoSuchHeaderException.class)
                .handled(true)
                .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(401))
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("Unauthorized - credentials required"));

        from("platform-http:/api/secure")
                .process(exchange -> {
                    String username = exchange.getIn().getHeader("X-Username", String.class);
                    String password = exchange.getIn().getHeader("X-Password", String.class);
                    if (username != null && password != null) {
                        exchange.getIn().setHeader(
                                ShiroSecurityConstants.SHIRO_SECURITY_TOKEN,
                                new ShiroSecurityToken(username, password));
                    }
                })
                .policy("shiroPolicy")
                .log("Authenticated user accessing secure endpoint")
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("Access granted - you have the required role"))
                .end();

        from("platform-http:/api/public")
                .log("Public endpoint accessed - no authentication required")
                .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
                .setBody(constant("This is a public endpoint"));
    }

    private SecurityPolicyProvider findShiroProvider() {
        for (SecurityPolicyProvider p : java.util.ServiceLoader.load(SecurityPolicyProvider.class)) {
            if ("shiro".equals(p.name())) {
                return p;
            }
        }
        throw new IllegalStateException("Shiro SecurityPolicyProvider not found on classpath");
    }
}
