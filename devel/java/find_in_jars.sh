#!/bin/bash

DEBUG=1
JAR_PATTERN=*.jar

# Error codes.
PARAM_ERROR=1
DIR_ERROR=2

if [ $# -ne 2 ]; then
	echo "Usage:  $0 dir grep-pattern";
	exit $PARAM_ERROR;
fi

echo "[ INFO ] Output            -> stdout (1)";
echo "[ INFO ] Debug information -> stderr (2)";

DIR="$1"
FIND_PATTERN="$2"

if [ ! -d "$DIR" -o ! -x "$DIR" ]; then
	echo "Directory $DIR is not readable or executable.";
	exit $DIR_ERROR;
fi

# Get all the file paths recursively.
# ls -R :
#    .:
#    cvs  java  svn  time_mem_calc  utils
#
#    ./cvs:
#    cvs_update.sh
#
#    ./java:
#    cmd.bat  compile.bat  diff.sh  find_in_jars.sh
#
# Transform to:
#    ./cvs ./java ./svn ./time_mem_calc ./utils
#    ./cvs/cvs_update.sh
#    ./java/cmd.bat ./java/compile.bat ./java/diff.sh ./java/find_in_jars.sh
#
ALL_FILES=`ls -R "$DIR" | awk 'BEGIN { prefix="." } /^.*:$/{ prefix=substr($1, 0, length($1) - 1) } /^.*[^:]$/{ print prefix "/" $1 }'`
#ALL_FILES=`find "$DIR1" -name "*" -print`

if [ $DEBUG -ge 2 ]; then
	echo "$ALL_FILES" >&2
fi

##
## $ALL_FILES will be as:
##    test1/1.jar
##    test1/2.jar
##
for i in $ALL_FILES
do
	JAR_FILE=$i
	if [ -f "$JAR_FILE" ]; then
		case "$JAR_FILE" in
			*.jar)
				if [ $DEBUG -ge 1 ]; then
					echo "Processing $JAR_FILE" >&2
				fi
				OUTPUT=`jar tf "$JAR_FILE" | grep "$FIND_PATTERN"`
				if [ ! -z "$OUTPUT" ]; then
					echo "[ Found in ${JAR_FILE} ]"
					echo "$OUTPUT"
					echo ""
				fi
				;;
		esac
	fi
done

echo "Done."
exit 0
