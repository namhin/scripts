#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:  $0  [ Dump file 1 ]  [ Dump file 2 ] [ Diff command: 'diff' (default) or 'meld' ]"
	exit 1
fi

NEW_LINE="\\
"
normalize_dump_file() {
	local dump_file
	dump_file="$1"

	sed -i ".bak" "s/),[[:space:]]*(/),${NEW_LINE}(/g" "${dump_file}"
	rm -rf "${dump_file}.bak"
}

DIFF_CMD="diff"
if [ $# -gt 2 ]; then DIFF_CMD="$3"; fi

normalize_dump_file "$1"
normalize_dump_file "$2"
${DIFF_CMD} "$1" "$2" | grep -v "Dump completed\|AUTO_INCREMENT"

