camel run main-route.camel.yaml application.properties company-knowledge-base.txt  \
      --dep=mvn:io.kaoto.forage:forage-in-memory-store:1.6.1 \
      --dep=mvn:io.kaoto.forage:forage-default-retrieval-augmentor:1.6.1