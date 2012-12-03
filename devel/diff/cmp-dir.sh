#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage:  $0 [ dir1 ]  [ dir2 ] [ 'meld' or 'diff' ]"
	exit 1
fi

DIR1="$1"
DIR2="$2"
CMP_CMD="$3"
if [ -z "${CMP_CMD}" ]; then CMP_CMD="meld" ;fi

if [ ! -d "$DIR1" -o ! -x "$DIR1" ]; then
	echo "Directory $DIR1 is not readable or executable."
	exit 1
fi

if [ ! -d "$DIR2" -o ! -x "$DIR2" ]; then
	echo "Directory $DIR2 is not readable or executable."
	exit 1
fi

. "`readlink -f "$0" | xargs dirname`/../generic.inc.sh"

FILE_LIST="file-list.txt"
DIFF_FILE="file-diff.sh"

echo "[ INFO ] Debug information -> stderr (2)" >&2
echo "[ INFO ] Command to diff   -> $DIFF_FILE" >&2

echo "" > "$DIFF_FILE"

find_ignoring_repo "$DIR1" "*" > "${FILE_LIST}"
FILE_NUM=`line_num_of_file "${FILE_LIST}"`
for i in `seq 1 ${FILE_NUM}`
do
	FILE1="`sed -n "${i}p" "${FILE_LIST}"`"
	FILE2=`echo "$FILE1 $DIR1 $DIR2" |  awk '{ temp=$1; sub($2, $3, temp); print temp }'`
	if [ ! -f "$FILE1" ]; then
		continue
	fi

	echo -n "Examining $FILE1"

	if [ ! -f "$FILE2" ]; then
		echo -e "\t\t[ Unavailable ]"
		continue
	fi

	diff "$FILE1" "$FILE2" 1>/dev/null
	if [ $? -eq 0 ]; then
		echo -e "\t\t[ OK ]"
		continue
	fi
	
	## Create the diffing command scripts.
	echo -e "\t\t[ Differ ]"
	echo -e "$CMP_CMD $FILE1 $FILE2" >> "$DIFF_FILE"
done

echo "Done" >&2
exit 0
