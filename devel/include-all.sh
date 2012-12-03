#!/bin/bash

INC_BASE_DIR="`dirname $0`"
for i in `find "${INC_BASE_DIR}" -name "*.inc.sh"`
do
	echo "${i}"
done

