# Check for latest archetype version at: http://mvnrepository.com/artifact/org.codehaus.mojo.archetypes/webapp-javaee7

read -p "Project Name: " project_name
if [ -z "${project_name}" ]; then exit 1; fi

read -p "Package (e.g., org.something.project): " package
if [ -z "${package}" ]; then exit 1; fi

read -p "Group Id: " group_id
if [ -z "${group_id}" ]; then exit 1; fi

mvn \
	-DarchetypeGroupId=org.codehaus.mojo.archetypes \
	-DarchetypeArtifactId=webapp-javaee7 \
	-DarchetypeVersion=1.1 \
	-DarchetypeRepository=https://nexus.codehaus.org/content/repositories/releases/ \
	-DgroupId=${group_id} \
	-DartifactId=${project_name} \
	-Dversion=0.1 \
	-Dpackage=${package} \
	-Darchetype.interactive=false \
	--batch-mode \
	--update-snapshots \
	archetype:generate

