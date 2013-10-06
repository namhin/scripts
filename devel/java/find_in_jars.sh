#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage:  $0  [ dir ]  [ grep-pattern ]";
	exit 1;
fi

DIR="$1"
FIND_PATTERN="$2"

if [ ! -d "$DIR" -o ! -x "$DIR" ]; then
	echo "Directory $DIR is not readable or executable.";
	exit 2;
fi

find "${DIR}" -name "*.jar" | while read file
do
	echo "Processing ${file}"
	if [ ! -z "`jar tf "${file}" | grep "${FIND_PATTERN}"`" ]; then
		echo "========> Found: ${file}"
	fi
done
