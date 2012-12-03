#!/bin/bash
MATCH_WITH_DIR=/opt/projects/kaz/ibfd/forum/test/roller-web-orig/org/apache/roller/weblogger/ui/rendering/model
FILENAME=
for i in `ls -1`
do
	FILENAME=`echo "$i" | awk 'BEGIN {FS="."} {print $1}'`
	if [ -f "${FILENAME}.class" ]; then
		diff "${FILENAME}.class" "${MATCH_WITH_DIR}/${FILENAME}.class" | awk '{printf "[ Modified ] %s\n", $3}'
	fi
done

exit 0
