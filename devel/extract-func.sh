#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage:  $0  [ /path/to/file ]  [ Function Name or Empty (for all functions) ]"
	exit 1
fi

EXTRACT_AWK="`readlink -f "$0" | xargs dirname`/extract-func.awk"
cat "$1" | awk -v func_name="$2" -f "${EXTRACT_AWK}"

