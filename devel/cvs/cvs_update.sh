#!/bin/bash
PROJECT=
if [ $# -eq 1 ]; then
	PROJECT=$1;
else
	read -p "Project? " PROJECT;
	if [ $? -ne 0 ]; then
		exit 1;
	fi
fi

# is project name is valid?
if [ -z "${PROJECT}" ]; then
	# No.
	echo "No project name is provided. Program will exit.";
	exit 1;
fi

# Go to the project directory.
cd "${PROJECT}"
if [ $? -ne 0 ]; then
	exit 1;
fi

# Update from the CVS and check is there any conflicts.
# -d: Create if there are new directories in the repository.
# -C: Override and write locally modified files.
# -P: Prune empty directories.
echo "Updating ${PROJECT} ..."
cvs update -d -C -P 2>/dev/null | grep "^C"

# We are done.
echo "Done."
exit 0;
