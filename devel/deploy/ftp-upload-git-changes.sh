#!/bin/bash

if [ $# -lt 5 ]; then
	echo "Usage:"
	echo "   $0  [ Commit number after which to be ftp-ed ]  [ Source Path ] [ Destination Path ] [ FTP Host ] [ FTP User ] [ Pattern to ignore ]"
	echo ""
	echo "Info:"
	echo "   It will upload the changes in current git repo."
	echo "   Source Path: path to the directory (relative to current dir) which will be uploaded"
	echo "   Destination Path: absolute path to FTP directory where to upload"
	echo "   FTP Host: as name means"
	echo "   FTP User: as name means"
	echo "   Pattern to ignore: regex to the files that are changed but not to be uploaded"
	exit 1
fi

BASE_DIR="`readlink -f "$0" | xargs dirname`"
. "${BASE_DIR}/../generic.inc.sh"

COMMIT_NO="$1"
SRC_PATH="$2"
DST_PATH="$3"
FTP_HOST="$4"
FTP_USER="$5"
if [ $# -gt 5 ]; then IGNORE_PAT="$6" ; else IGNORE_PAT= ; fi

FTP_CMD_FILE="ftp-cmd.txt"
CHANGED_FILES="changed-files.txt"
CHANGED_DIRS="changed-dirs.txt"
SLASH="\\"

SRC_PATH_ESC="`escape_regex_chars "${SRC_PATH}" | sed "s/\//${SLASH}${SLASH}\//g"`"
DST_PATH_ESC="`escape_regex_chars "${DST_PATH}" | sed "s/\//${SLASH}${SLASH}\//g"`"

git log --format=format:"" --name-only "${COMMIT_NO}...HEAD" "${SRC_PATH}" | grep -v "^[[:space:]]*$" | sort | uniq > "${CHANGED_FILES}"

# Remove uncommitting files.
if [ ! -z "${IGNORE_PAT}" ]; then
	IGNORE_PAT="`echo "${IGNORE_PAT}" | sed "s/\//${SLASH}${SLASH}\//g"`"
	echo "Ignoring files having pattern: ${IGNORE_PAT}"
	sed -i".bak" "/${IGNORE_PAT}/d" "${CHANGED_FILES}"
fi

CHANGED_FILES_NUM=`cat "${CHANGED_FILES}" | wc -l`

cat "${CHANGED_FILES}" | sed "s/\(.*\)\/.*/\1/g" | sort | uniq > "${CHANGED_DIRS}"
CHANGED_DIRS_NUM=`cat "${CHANGED_DIRS}" | wc -l`

# Write down all the FTP commands.
echo -n "" > "${FTP_CMD_FILE}"
echo "lcd `pwd`" >> "${FTP_CMD_FILE}"

###############################################################################
# Directory ensurance.
for i in `seq 1 ${CHANGED_DIRS_NUM}`
do
	dir_to_ensure="`sed -n "${i}p" "${CHANGED_DIRS}" | sed "s/^${SRC_PATH_ESC}\//${DST_PATH_ESC}\//g"`"
		echo "
echo \"Ensuring ${dir_to_ensure}\"...
mkdir -p \"${dir_to_ensure}\"
" >> "${FTP_CMD_FILE}"
done


###############################################################################
for i in `seq 1 ${CHANGED_FILES_NUM}`
do
	file_to_copy="`sed -n "${i}p" "${CHANGED_FILES}"`"
	if [ -z "${file_to_copy}" ]; then continue; fi
	
	dst_file="`echo "${file_to_copy}" | sed "s/^${SRC_PATH_ESC}\//${DST_PATH_ESC}\//g"`"

	# Removal.
	if [ ! -e "${file_to_copy}" ]; then
		echo "
echo \"Removing ${dst_file}\"...
rm -rf \"${dst_file}\"
" >> "${FTP_CMD_FILE}"
		continue
	fi

	# Copy
	echo "
echo \"Copying ${file_to_copy}\"...
put \"${file_to_copy}\" -o \"${dst_file}\"
" >> "${FTP_CMD_FILE}"

done


# Execute all the written FTP commands.
read -p "FTP commands gathered in ${FTP_CMD_FILE}. Execute (${SRC_PATH} --> ${DST_PATH})? (y/n) " CHOICE
if [ "${CHOICE}" = "y" ]; then
	read -s -p "FTP Pass? " FTP_PASS
	if [ -z "${FTP_PASS}" ]; then
		echo "FTP Pass not found."
		exit 1
	fi
	echo ""

	lftp -u "${FTP_USER}","${FTP_PASS}" "${FTP_HOST}" < "${FTP_CMD_FILE}"
fi

read -p "DONE. Remove temporary files? (y/n) " CHOICE
if [ "${CHOICE}" = "y" ]; then
	rm -rf "${CHANGED_FILES}"
	rm -rf "${CHANGED_FILES}.bak"
	rm -rf "${CHANGED_DIRS}"
	rm -rf "${FTP_CMD_FILE}"
fi

