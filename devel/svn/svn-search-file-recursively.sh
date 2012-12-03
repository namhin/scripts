#!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: $0 [ svn base url (https://host.com/repo) ]  [ initial dir within svn base ]  [ file name regex to search ]"
	exit 1
fi

DIR_PATH="svn-dir-path.txt"
SLASH="\\"

SVN_BASE="$1"
SVN_URL_ESCAPED="`echo "${SVN_BASE}" | sed "s/\//${SLASH}${SLASH}\//g"`"

# Initial line
echo "${SVN_BASE}/$2" > "${DIR_PATH}"

SEARCHING_REGEX="$3"
dir_index=1

for i in `seq 1 100000`
do
	a_dir="`sed -n "${dir_index}p" "${DIR_PATH}"`"
	if [ -z "${a_dir}" ]; then
		break
	fi
	dir_index=`echo "${dir_index} + 1" | bc`

	echo "[ C ] Checking in: ${a_dir}"	
	files_in_svn="`svn ls "${a_dir}"`"
	found_str="`echo "${files_in_svn}" | grep "${SEARCHING_REGEX}"`"
	if [ ! -z "${found_str}" ]; then
		echo "[ F ] Found within ( ${a_dir} ) as ( ${found_str} )"
		break
	fi

	a_dir_escaped="`echo "${a_dir}" | sed "s/\//${SLASH}${SLASH}\//g"`"
	echo "${files_in_svn}" | grep ".*\/" | sed "s/\(.*\)\//${a_dir_escaped}\/\1/g" >> "${DIR_PATH}"
done

