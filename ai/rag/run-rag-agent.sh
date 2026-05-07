camel run main-route.camel.yaml forage-agent-factory.properties company-knowledge-base.txt  \
      --dep=mvn:io.kaoto.forage:forage-in-memory-store:1.3-SNAPSHOT \
      --dep=mvn:io.kaoto.forage:forage-default-retrieval-augmentor:1.3-SNAPSHOT