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

commit_no="$1"
src_path="$2"
dst_path="$3"
ftp_host="$4"
ftp_user="$5"
if [ $# -gt 5 ]; then ignore_pat="$6" ; else ignore_pat= ; fi

ftp_cmd_file="ftp-cmd.txt"
changed_files="changed-files.txt"
changed_dirs="changed-dirs.txt"
slash="\\"

src_path_escaped="`escape_regex_chars "${src_path}" | sed "s/\//${slash}${slash}\//g"`"
dst_path_escaped="`escape_regex_chars "${dst_path}" | sed "s/\//${slash}${slash}\//g"`"

git log --format=format:"" --name-only "${commit_no}...HEAD" "${src_path}" | grep -v "^[[:space:]]*$" | sort | uniq > "${changed_files}"

# Remove uncommitting files.
if [ ! -z "${ignore_pat}" ]; then
	ignore_pat="`echo "${ignore_pat}" | sed "s/\//${slash}${slash}\//g"`"
	echo "Ignoring files having pattern: ${ignore_pat}"
	sed -i".bak" "/${ignore_pat}/d" "${changed_files}"
fi

changed_files_num=`cat "${changed_files}" | wc -l`

cat "${changed_files}" | sed "s/\(.*\)\/.*/\1/g" | sort | uniq > "${changed_dirs}"
changed_dirs_num=`cat "${changed_dirs}" | wc -l`

# Write down all the FTP commands.
echo -n "" > "${ftp_cmd_file}"
echo "lcd `pwd`" >> "${ftp_cmd_file}"

###############################################################################
# Directory ensurance.
for i in `seq 1 ${changed_dirs_num}`
do
	dir_to_ensure="`sed -n "${i}p" "${changed_dirs}" | sed "s/^${src_path_escaped}\//${dst_path_escaped}\//g"`"
		echo "
echo \"Ensuring ${dir_to_ensure}\"...
mkdir -p \"${dir_to_ensure}\"
" >> "${ftp_cmd_file}"
done


###############################################################################
for i in `seq 1 ${changed_files_num}`
do
	file_to_copy="`sed -n "${i}p" "${changed_files}"`"
	if [ -z "${file_to_copy}" ]; then continue; fi
	
	dst_file="`echo "${file_to_copy}" | sed "s/^${src_path_escaped}\//${dst_path_escaped}\//g"`"

	# Removal.
	if [ ! -e "${file_to_copy}" ]; then
		echo "
echo \"Removing ${dst_file}\"...
rm -rf \"${dst_file}\"
" >> "${ftp_cmd_file}"
		continue
	fi

	# Copy
	echo "
echo \"Copying ${file_to_copy}\"...
put \"${file_to_copy}\" -o \"${dst_file}\"
" >> "${ftp_cmd_file}"

done


# Execute all the written FTP commands.
read -p "FTP commands gathered in ${ftp_cmd_file}. Execute (${src_path} --> ${dst_path})? (y/n) " CHOICE
if [ "${CHOICE}" = "y" ]; then
	read -s -p "FTP Pass? " FTP_PASS
	if [ -z "${FTP_PASS}" ]; then
		echo "FTP Pass not found."
		exit 1
	fi
	echo ""

	lftp -u "${ftp_user}","${FTP_PASS}" "${ftp_host}" < "${ftp_cmd_file}"
fi

read -p "DONE. Remove temporary files? (y/n) " CHOICE
if [ "${CHOICE}" = "y" ]; then
	rm -rf "${changed_files}"
	rm -rf "${changed_files}.bak"
	rm -rf "${changed_dirs}"
	rm -rf "${ftp_cmd_file}"
fi

