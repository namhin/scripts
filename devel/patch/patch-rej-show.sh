#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:  $0  [ /path/to/project/to/compare/with ] [ Diff command (exmaple: 'meld', 'diff') ]  [ File extension (example: rej, orig) ]"
	exit 1
fi

COMPARING_PROJECT="$1"
DIFF_CMD="$2"
if [ $# -gt 2 ]; then FILE_EXT="$3"; else FILE_EXT="rej"; fi

for i in `find . -name "*.${FILE_EXT}"`
do
	echo "Handling the rejection: ${i}"
	file="`echo "${i}" | sed "s/\.${FILE_EXT}$//g"`"
	"${DIFF_CMD}" "${file}" "${COMPARING_PROJECT}/${file}"
done

