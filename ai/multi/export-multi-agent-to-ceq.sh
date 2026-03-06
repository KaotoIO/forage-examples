camel export --runtime=quarkus \
	--dir=ceq-example multi-agent.camel.yaml application.properties \
	--dep=mvn:io.kaoto.forage:forage-agent:1.1-SNAPSHOT \
	--dep=mvn:io.kaoto.forage:forage-memory-message-window:1.1-SNAPSHOT \
	--dep=mvn:io.kaoto.forage:forage-model-google-gemini:1.1-SNAPSHOT \
	--dep=mvn:io.kaoto.forage:forage-model-ollama:1.1-SNAPSHOT

# then, to run:
# cd ceq-example
# mvn quarkus:dev
