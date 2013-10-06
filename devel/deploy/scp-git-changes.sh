#!/bin/bash

if [ $# -lt 5 ]; then
	echo "Usage:"
	echo "   $0  [ Commit number after which to be scp-ed ]  [ Source Path ] [ Destination Path ] [ SCP Host ] [ SCP User ] [ Pattern to ignore ]"
	echo ""
	echo "Info:"
	echo "   It will upload the changes in current git repo."
	echo "   Source Path: path to the directory (relative to current dir) which will be uploaded"
	echo "   Destination Path: absolute path to SCP directory where to upload"
	echo "   SCP Host: as name means"
	echo "   SCP User: as name means"
	echo "   Pattern to ignore: regex to the files that are changed but not to be uploaded"
	exit 1
fi

BASE_DIR="`readlink -f "$0" | xargs dirname`"
. "${BASE_DIR}/../generic.inc.sh"

commit_no="$1"
src_path="$2"
dst_path="$3"
scp_host="$4"
scp_user="$5"
if [ $# -gt 5 ]; then ignore_pat="$6" ; else ignore_pat= ; fi

scp_cmd_file="scp-cmd.txt"
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

# Write down all the SCP commands.
echo -n "" > "${scp_cmd_file}"

###############################################################################

get_dst_path() {
	echo "$1" | sed "s/^${src_path_escaped}\//${dst_path_escaped}\//g" | sed "s/^${src_path_escaped}$/${dst_path_escaped}/g"
}

get_changed_dirs() {
	cat "${changed_dirs}" | while read changed_dir
	do
		echo -n -e "\n\t\"`get_dst_path "${changed_dir}"`\""
	done
}

cmd_to_ensure_dirs() {
	dirs_to_ensure="`get_changed_dirs`"
	if [ ! -z "${dirs_to_ensure}" ]; then
		echo -e "ssh ${scp_user}@${scp_host} 'mkdir -p ${dirs_to_ensure}\n'" >> "${scp_cmd_file}"
	fi
}

get_removed_files() {
	cat "${changed_files}" | while read changed_file
	do
		if [ ! -z "${changed_file}" -a ! -e "${changed_file}" ]; then
			echo -n -e "\n\t\"`get_dst_path "${changed_file}"`\""
		fi
	done
}

cmd_to_remove_files() {
	files_to_remove="`get_removed_files`"
	if [ ! -z "${files_to_remove}" ]; then
		echo -e "ssh ${scp_user}@${scp_host} 'rm -rf ${files_to_remove}\n'" >> "${scp_cmd_file}"
	fi
}

cmd_to_copy_files() {
	cat "${changed_files}" | while read changed_file
	do
		if [ ! -z "${changed_file}" -a -e "${changed_file}" ]; then
			echo "scp \"${changed_file}\" ${scp_user}@${scp_host}:\"`get_dst_path "${changed_file}"`\"" >> "${scp_cmd_file}"
		fi
	done
}

###############################################################################

cmd_to_ensure_dirs
cmd_to_remove_files
cmd_to_copy_files

echo "== Command to execute ===================================="
cat "${scp_cmd_file}"

# Execute all the written SCP commands.
read -p "Execute (${src_path} --> ${dst_path})? (y/n) " choice
if [ "${choice}" = "y" ]; then
	. "${scp_cmd_file}"
fi

read -p "DONE. Remove temporary files? (y/n) " choice
if [ "${choice}" = "y" ]; then
	rm -rf "${changed_files}"
	rm -rf "${changed_files}.bak"
	rm -rf "${changed_dirs}"
	rm -rf "${scp_cmd_file}"
fi

