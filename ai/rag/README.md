# Camel Forage naive AI RAG Example

This example demonstrates how to use Camel Forage to automatically configure an AI agent with RAG model based on the lcal file.

## Prerequisites

1. **Ollama** running on `http://localhost:11434` with `granite4:3b` and `nomic-embed-text` models.
   Follow https://docs.ollama.com/quickstart for the installation instructions.

## Configuration

The `forage-agent-factory.properties` file configures the AI agent:

- **chat model**: Provided by `ollama` - model **granite4:3b**
- **embedding model**: Provided by `ollama` - model **nomic-embed-text**
- **knowledge base**: `company-knowledge-base.txt` - file with information used to populate in-memory embedding store

## Running the Example

### Using Camel JBang (Java DSL)

```bash
camel run main-route.camel.yaml forage-agent-factory.properties company-knowledge-base.txt  \
      --dep=mvn:io.kaoto.forage:forage-agent:1.0-SNAPSHOT \
      --dep=mvn:io.kaoto.forage:forage-model-embeddings-ollama:1.0-SNAPSHOT \
      --dep=mvn:io.kaoto.forage:forage-in-memory-store:1.0-SNAPSHOT \
      --dep=mvn:io.kaoto.forage:forage-default-retrieval-augmentor:1.0-SNAPSHOT \
      --dep=mvn:io.kaoto.forage:forage-model-ollama:1.0-SNAPSHOTun Route.java --dep=org.apache.camel.forage:forage-jms-artemis:1.0-SNAPSHOT --dep=org.apache.camel.forage:forage-jms:1.0-SNAPSHOT
```

or run the script

```bash
run-rag-agent.sh
```


## Features Demonstrated

- ✅ Automatic Ai agent with RAG is constructed via Forage and used in the camel route
- ✅ Zero boilerplate - no manual AI model related setup needed

## Execution result

The route once sends a question to the chat model `Describe the Miles of Camels Car Rental cancellations policy for cancelling 24 hours before pickup. What is the refund amount?`
The response is written into console. Based on the information from the `company-knowledge-base.txt`, the answer should contain staement similar to this one: `full refund would be given when cancelling 24 hours before pickup.`


When the route is started without the RAG -> use the command
```bash
camel run main-route.camel.yaml forage-agent-factory.properties company-knowledge-base.txt  \
      --dep=mvn:io.kaoto.forage:forage-agent:1.0-SNAPSHOT \
      --dep=mvn:io.kaoto.forage:forage-model-ollama:1.0-SNAPSHOT
```

The response does not contain full refund confirmation and should contain a disclaimer, that the terms may vary.
