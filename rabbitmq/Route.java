package com.foo.acme;

import org.apache.camel.builder.RouteBuilder;

public class Route extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("timer:producer?period=5000")
                .setBody(constant("Hello from Camel Forage Spring RabbitMQ!"))
                .to("spring-rabbitmq:test.exchange?routingKey=test")
                .log("Message sent to RabbitMQ exchange");

        from("spring-rabbitmq:test.exchange?queues=test.queue&routingKey=test")
                .log("Message received from RabbitMQ: ${body}");
    }
}
