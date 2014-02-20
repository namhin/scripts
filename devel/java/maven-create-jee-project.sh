# Check for latest archetype version at: http://mvnrepository.com/artifact/org.codehaus.mojo.archetypes/webapp-javaee7
mvn \
	-DarchetypeGroupId=org.codehaus.mojo.archetypes \
	-DarchetypeArtifactId=webapp-javaee7 \
	-DarchetypeVersion=1.1 \
	-DarchetypeRepository=https://nexus.codehaus.org/content/repositories/releases/ \
	-DgroupId=com.ws.quiztimate \
	-DartifactId=quiztimate \
	-Dversion=0.1 \
	-Dpackage=com.ws.quiztimate \
	-Darchetype.interactive=false \
	--batch-mode \
	--update-snapshots \
	archetype:generate

