camel export --runtime=spring-boot \
	--dir=csb-example multi-agent.camel.yaml application.properties \
	--dep=mvn:io.kaoto.forage:forage-agent:1.0-SNAPSHOT \
	--dep=mvn:io.kaoto.forage:forage-memory-message-window:1.0-SNAPSHOT \
	--dep=mvn:io.kaoto.forage:forage-model-google-gemini:1.0-SNAPSHOT \
	--dep=mvn:io.kaoto.forage:forage-model-ollama:1.0-SNAPSHOT

# then, to run:
# cd csb-example
# mvn spring-boot:run
