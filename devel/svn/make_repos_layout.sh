#!/bin/bash
#
# This script will create a SVN repository from an ordinary project directoy.
# Following figure shows possible initial directory-tree and corresponding
# output:
#
#    1) + Project           -------->    1) + Project
#       |                                   |
#       +++++ Files & Dirs                  +++++ tags
#                                           |
#                                           +++++ branches
#                                           |
#                                           +++++ trunk
#                                               |
#                                               +++++ Files & Dirs
#
#
#    2) + Project           -------->    2) + Project
#       |                                   |
#       +++++ Child Project #1              +++++ Child Project #1
#       |   |                               |   |
#       |   +++++ Files & Dirs              |   +++++ tags
#       |                                   |   |
#       +++++ Child Project #2              |   +++++ branches
#           |                               |   |
#           +++++ Files & Dirs              |   +++++ trunk
#       ......................              |       |
#       ......................              |       +++++ Files & Dirs
#                                           |
#                                           +++++ Child Project #2
#                                           ..........................
#                                           ..........................
#

TAGS=tags
BRANCHES=branches
TRUNK=trunk

#
#
#
doTagBranchTrunk() {
	mkdir "$TAGS" "$BRANCHES" "$TRUNK"
	if [ $? -ne 0 ]; then
		exit 1;
	fi

	mv "$GINIPIG"/* "$TRUNK"
	if [ $? -ne 0 ]; then
		exit 1;
	fi

	mv "$TAGS" "$BRANCHES" "$TRUNK" "$GINIPIG"/
	if [ $? -ne 0 ]; then
		exit 1;
	fi
}

# Input the directory name of the project.
PRODIR=
if [ $# -eq 1 ]; then
	PRODIR="$1"
	echo "Project Directory: $PRODIR"
else
	echo -e -n "Project Directory: "
	read PRODIR
	if [ -z "$PRODIR" ]; then
		echo "No project directory is specified. Program will exit."
		exit 1;
	fi
fi
if [ ! -d "$PRODIR" ]; then
	echo "$PRODIR is not a directory."
	exit 1;
fi

# Input the type of the porject.
PARENT=
echo -e -n "Does it contain children projects? (y/n, default no) "
read PARENT

if [ -z "$PARENT" -o "$PARENT" = "N" ]; then PARENT=n
elif [ "$PARENT" = "Y" ]; then PARENT=y
fi

if [ "$PARENT" != "y" -a "$PARENT" != "n" ]; then
	echo "Invalid input \"$PARENT\""
	exit 1;
fi

if [ "$PARENT" = "y" ]; then
	for i in $PRODIR/*
	do
		if [ -d $i ]; then
			echo -e "Processing \"${i}\"..."
			GINIPIG=$i
			doTagBranchTrunk
		fi
	done
else
	GINIPIG=$PRODIR
	doTagBranchTrunk
fi

echo "Successful"
exit 0
