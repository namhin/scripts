#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:  $0  [ /path/to/dir1 ] [ /path/to/dir2 ]  [ File where to save (default: t.txt) ]"
	exit 1
fi

if [ $# -ge 3 ]; then
	SAVE_FILE="$3"
else
	SAVE_FILE="t.txt"
fi

"`readlink -f "$0" | xargs dirname`/cmp-dir.sh" "$1" "$2" | \
	grep -v "OK\|\.class\|\.log\|\.settings\|\<antbuild\/\|\<build\/\|\<junk\/\|\<bin\/" | \
	sort | uniq > "${SAVE_FILE}"

