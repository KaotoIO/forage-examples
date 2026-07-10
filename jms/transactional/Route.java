import org.apache.camel.builder.RouteBuilder;

public class Route extends RouteBuilder {

    @Override
    public void configure() throws Exception {

        // Producer - sends messages to input queue
        from("timer:producer?period=10000")
                .setBody(constant("Transactional message"))
                .to("jms:queue:input.queue")
                .log("Sent message to input queue");

        // Transactional consumer - processes messages within XA transaction
        // transacted must stay false with XA: the JTA transaction manager wired into the
        // JMS component drives the transaction (IBM MQ rejects local transactions on XA
        // connections with MQRC 2072)
        from("jms:queue:input.queue?cacheLevelName=CACHE_NONE")
                .transacted("PROPAGATION_REQUIRED")
                .log("Processing message: ${body}")
                .choice()
                    .when(simple("${random(0,10)} > 7"))
                        .log("Simulating error - message will be rolled back")
                        .throwException(new RuntimeException("Simulated processing error"))
                    .otherwise()
                        .log("Processing successful - committing transaction")
                        .to("jms:queue:output.queue")
                        .log("Message forwarded to output queue")
                .end();

        // Consumer for successfully processed messages
        from("jms:queue:output.queue")
                .log("Successfully processed message: ${body}");

        // Dead Letter Queue consumer
        from("jms:queue:DLQ")
                .log("Message sent to DLQ after max redeliveries: ${body}");
    }
}
