#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:  $0  [ /path/to/project/to/copy/from ]  [ /path/to/file.diff ]"
	exit 1
fi

BASE_PROJECT="$1"
DIFF_FILE="$2"

get_binary_file_path() {
   awk '
      /^Index:/{
         binary_file=$2
      }
      /.*application\/octet-stream/{
         print binary_file
      }
   '
}

CHANGED_FILES="`cat "${DIFF_FILE}" | get_binary_file_path`"
echo "${CHANGED_FILES}" | xargs -I FILE /bin/cp "${BASE_PROJECT}/FILE" FILE

echo "______________________"
echo "Updated files:"
echo "~~~~~~~~~~~~~~~~~~~~~~"
echo "${CHANGED_FILES}"

