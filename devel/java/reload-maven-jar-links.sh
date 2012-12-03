#!/bin/bash

REPO="repository"
if [ $# -gt 1 ]; then REPO="$1"; shift 1; fi

DST="jars"
if [ $# -gt 1 ]; then DST="$1"; shift 1; fi

BASE_DIR="`pwd`"

for i in `find "$BASE_DIR/$DST" -name "*.jar"`
do
	unlink "$i"
done

for i in `find "$BASE_DIR/$REPO" -type f -a -name "*.jar"`
do
	ln -s "$i" "$BASE_DIR/$DST/`basename "$i"`"
done

exit 0
