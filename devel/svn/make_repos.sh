#!/bin/bash
#
# It is designed to be run by root. Keep it in the base directory (say, "svnroot").
# Assumption:
#    1) A group named "developer" exists whose members are developers.
#    2) Developers cannot create a repository. Only root does this.
#    3) Developers can import, commit.
#
GRP_NAME=developer
REPOS_NAME=

echo "New repository is going to be created for the group: $GRP_NAME"

# Any project name given as a parameter?
if [ $# -eq 1 ]; then
	# Yes.
	REPOS_NAME="$1"
	echo "Repository Name: $REPOS_NAME"
else
	# Input the repository name.
	echo -n "Repository Name: "
	read REPOS_NAME
	if [ -z "$REPOS_NAME" ]; then
		echo "No repository name is given.";
		exit 1;
	fi
fi

echo "Creating Repository....."
svnadmin create "$REPOS_NAME"
if [ $? -ne 0 ]; then exit 1; fi

echo "Restricting anonymous access to $REPOS_NAME....."
chmod 750 "$REPOS_NAME"
if [ $? -ne 0 ]; then exit 1; fi

echo "Owning to $GRP_NAME....."
chown :$GRP_NAME "$REPOS_NAME" "$REPOS_NAME"/db "$REPOS_NAME"/db/revprops "$REPOS_NAME"/db/revs "$REPOS_NAME"/db/transactions "$REPOS_NAME"/db/write-lock
if [ $? -ne 0 ]; then exit 1; fi

echo "Giving committing permission to $GRP_NAME....."
chmod g+w "$REPOS_NAME"/db "$REPOS_NAME"/db/revprops "$REPOS_NAME"/db/revs "$REPOS_NAME"/db/transactions "$REPOS_NAME"/db/write-lock
if [ $? -ne 0 ]; then exit 1; fi

echo "Successful."
exit 0
