#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:  $0"
	echo "   [ Repository From: 'https://host.com/repo/trunk' or 'https://host.com/repo/branches/branch_1' or ... ]"
	echo "   [ Revision Info: '1234' ( Means this revision ) or '1234:1300' ( Means from 1234 to 1300. Both are inclusive ) ]"
	echo "   [ Patch type: 1           => svn-merge-with-reintegrate"
	echo "                 2 (default) => svn-merge-without-reintegrate"
	echo "                 0           => diff-and-patch ]"
	exit 1
fi

CODE_SOURCE="$1"
REVISION_INFO="$2"
if [ $# -ge 3 ]; then PATCH_TYPE=$3; else PATCH_TYPE=2; fi

PROJECT="`echo "${CODE_SOURCE}" | sed "s/.*\/\(.*\)/\1/g"`"
SAVING_FILE="${PROJECT}_diff_${REVISION_START}_${REVISION_END}.diff"
PATCH_DST="`pwd`"
BACK_SLASH="\\"

fix_revision_start() {
	if [ -z "`echo "${REVISION_INFO}" | grep ":"`" ]; then
		REVISION_START=${REVISION_INFO}
		REVISION_END=${REVISION_INFO}
	else
		REVISION_START=`echo "${REVISION_INFO}" | sed -E "s/(.+):(.+)/\1/g" | bc`
		REVISION_END=`echo "${REVISION_INFO}" | sed -E "s/(.+):(.+)/\2/g" | bc`
	fi

	# svn diff/merge expects exclusive start and we are receiving inclusive start.
	REVISION_START=`echo "${REVISION_START} - 1" | bc`
}

escape_for_regex() {
	BACK_SLASH="\\"
	echo "$1" | sed "s/\//${BACK_SLASH}${BACK_SLASH}\//g"
}

determine_svn_base() {
	SVN_URL="${CODE_SOURCE}"
	SVN_URL_ESCAPED="`escape_for_regex ${SVN_URL}`"

	for i in tags branches trunk
	do
		SVN_BASE="`echo "${SVN_URL}" | sed "s/\(.*\)\/${i}\/.*/\1/g"`"
		if [ "${SVN_BASE}" != "${SVN_URL}" ]; then break; fi
	done
	SVN_BASE_ESCAPED="`escape_for_regex "${SVN_BASE}"`"
}

get_added_or_deleted_path() {
	awk '
		/)$/{
			skip = 1
		}
		{
			if (skip != 1) {
				print $0
			} else {
				printf "[ S ] Skipping %s\n", $0 > "/dev/stderr"
			}
			skip = 0
		}
	'
}

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

add_remote_files() {
	local added_files
	local deleted_files_path

	if [ $# -lt 1 -o -z "$1" ]; then
		return
	fi

	added_files="$1"

	echo "------------------------------------------------------------"
	echo "[ A ] Added files:"
	echo "${added_files}"

	## Patching can handle file addition. Just show that we have additions.
	## We needn't add files manually but we need to remove them. Otherwise
	## same content will be added twice by the patch.
	deleted_files_path="`echo "${added_files}" | sed "s/^[[:space:]]\+A \(\/.*\)/${SVN_BASE_ESCAPED}\1/g" | get_added_or_deleted_path`"
	delete_files "${deleted_files_path}"

	echo ""
}

delete_local_files() {
	local deleted_files
	local deleted_files_path

	if [ $# -lt 1 -o -z "$1" ]; then
		return
	fi

	deleted_files="$1"

	echo "------------------------------------------------------------"
	echo "[ D ] Deleted files:"
	echo "${deleted_files}"

	deleted_files_path="`echo "${deleted_files}" | sed "s/^[[:space:]]\+D \(\/.*\)/${SVN_BASE_ESCAPED}\1/g" | get_added_or_deleted_path`"
	delete_files "${deleted_files_path}"

	echo ""
}

delete_files() {
	local deleted_files_path
	local src_file
	local dst_file

	deleted_files_path="$1"

	# Sometimes a repo (tags or branches) doesn't exist at a revision
	# In this case, svn will return file path based on trunk.
	for src_file in ${deleted_files_path}
	do
		if [ -z "`echo "${src_file}" | grep "${SVN_URL_ESCAPED}"`" ]; then
			echo ""
			echo "[ ERROR ] Affected file's path is not as expected. Specified revision may not exist in ${SVN_URL}."
			exit 1
		fi
	done

	if [ ! -z "${deleted_files_path}" ]; then
		read -p "Proceed deleting from local system (y/n)? " CHOICE
		if [ -z "${CHOICE}" -o "${CHOICE}" = "n" -o "${CHOICE}" = "N" ]; then echo "[ D ] Deletion aborted"; return; fi
	fi

	for src_file in ${deleted_files_path}
	do
		dst_file="`echo "${src_file}" | sed "s/${SVN_URL_ESCAPED}\///g"`"

		echo "[ D ] rm ${dst_file}"
		rm -rf "${dst_file}"
	done
}

get_added_or_deleted_files() {
	local log_start
	local log_end
	local added_or_deleted_files
	local added_files
	local added_files_path
	local deleted_files
	local src_file
	local dst_file

	log_start="`echo "${REVISION_START} + 1" | bc`"
	log_end="${REVISION_END}"

	echo "[ L ] Fetching list of files added/deleted from ${log_start} --> ${log_end}"
	added_or_deleted_files="`svn log -v ${SVN_URL} -r ${log_start}:${log_end}`"

	## Patching cannot handle file deletion. So, do it here.
	delete_local_files "`echo "${added_or_deleted_files}" | grep "^[[:space:]]\+D \/"`"

	## Patching can handle file addition. Just show that we have additions.
	add_remote_files "`echo "${added_or_deleted_files}" | grep "^[[:space:]]\+A \/"`"
}

create_and_apply_patch() {
	local msg

	echo "Patch:"
	echo "   From: ${CODE_SOURCE}@${REVISION_START} ---> ${CODE_SOURCE}@${REVISION_END}"
	echo "     To: ${PATCH_DST}"
	read -p "Proceed (y/n)? " CHOICE
	if [ -z "${CHOICE}" -o "${CHOICE}" = "n" -o "${CHOICE}" = "N" ]; then echo "Aborted"; exit 2; fi

	if [ ${PATCH_TYPE} -eq 1 ]; then
		SVN_CMD="svn merge --reintegrate -r ${REVISION_START}:${REVISION_END} ${SVN_URL} ${PATCH_DST}"
		echo "${SVN_CMD}"
		${SVN_CMD}
	elif [ ${PATCH_TYPE} -eq 2 ]; then
		SVN_CMD="svn merge -r ${REVISION_START}:${REVISION_END} ${SVN_URL} ${PATCH_DST}"
		echo "${SVN_CMD}"
		${SVN_CMD}
	else
		get_added_or_deleted_files
		
		echo "[ D ] Diffing and saving at ${SAVING_FILE}"
		svn diff --old=${SVN_URL}@${REVISION_START} --new=${SVN_URL}@${REVISION_END} > ${SAVING_FILE} 
		if [ $? -ne 0 ]; then echo "Unable to created diff. Aborting further process."; exit 3; fi

		read -p "${SAVING_FILE} created. Proceed patching (y/n)? " CHOICE
		if [ -z "${CHOICE}" -o "${CHOICE}" = "n" -o "${CHOICE}" = "N" ]; then echo "Aborted"; exit 2; fi

		echo "[ P ] Patching from ${SAVING_FILE}"
		cd "${PATCH_DST}"
		patch -p0 < "${SAVING_FILE}"

		msg="`cat "${SAVING_FILE}" | get_binary_file_path`"
		if [ ! -z "${msg}" ]; then
			echo ""
			echo "_________________________________________________"
			echo "Please merge the following binary files manually:"
			echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
			echo "${msg}"
		fi
	fi
}

fix_revision_start
determine_svn_base
create_and_apply_patch

exit 0

