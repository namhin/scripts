#!/bin/bash

##
## If there exists a .svnignore file in current directory, then this command will handle following commands specially:
##    svn stat: Will filter stat output so that ignored files are not shown.
##    svn commit: Will not allow to commit ALL files (without specifying file names) if a modified file are ignored.
##
## .svnignore will contain the regular expression that will filter out the output of original 'svn stat'.
## It accepts REGEX supported by the command 'grep'. Example content of this file,
##    ^\?[[:space:]]*\.svnignore
##    ^\?[[:space:]]*\.project
##    ^\?[[:space:]]*antbuild
##    ^M[[:space:]]*antconfig/localhost\.conf
##

BASE_SVN="/usr/bin/svn-builtin"
SVN_IGNORE=".svnignore"
SLASH="\\"

if [ $# -eq 0 ];             then ${BASE_SVN} "$@"; exit 0; fi
if [ ! -e "${SVN_IGNORE}" ]; then ${BASE_SVN} "$@"; exit 0; fi

SVN_CMD="$1"

svn_stat() {
	local stat_out

	stat_out="`${BASE_SVN} "$@"`"
	IGNORE_REGEX_LINE=`cat "${SVN_IGNORE}" | wc -l`
	for line_num in `seq 1 ${IGNORE_REGEX_LINE}`
	do
		IGNORE_REGEX="`sed -n "${line_num}p" "${SVN_IGNORE}" | sed "/^[[:space:]]*#.*$/d;/^[[:space:]]*$/d"`"
		if [ -z "${IGNORE_REGEX}" ]; then
			continue
		fi
		stat_out="`echo "${stat_out}" | grep -v -i "${IGNORE_REGEX}"`"
	done
	echo "${stat_out}"
}

svn_show_which_files_to_commit() {
	echo -e "\e[1;31m$1. Following files are ignored:\n`echo "$2" | sed "s/^/${SLASH}${SLASH}t/g"`\e[0m"
	echo -e -n "\e[1;38mPlease commit the following files:\n\t\e[0m"
	svn_stat "stat" | sed "s/^.[[:space:]]*\(.*\)/\1/g" | tr "\n" " "
	echo ""
}

svn_commit() {
	local modified_files
	local m_option_found_at
	
	# We MUST have '-m' option.
	m_option_found_at=0
	for i in `seq 1 $#`
	do
		if [ "${!i}" = "-m" ]; then
			m_option_found_at=${i}
			break
		fi
	done
	if [ ${m_option_found_at} -eq 0 ]; then
		echo -e "\e[1;31mMissing '-m' option.\e[0m Usage:\n\tsvn commit file1, file2, ... -m \"Commit message\""
		return 1
	elif [ ${m_option_found_at} -eq $# ]; then
		echo -e "\e[1;31mMissing commit message in '-m' option.\e[0m Usage:\n\tsvn commit file1, file2, ... -m \"Commit message\""
		return 1
	fi
	
	# Commit all modified (ignoring .svnignore)
	modified_files="`cat "${SVN_IGNORE}" | grep "^\(\^M\|M\)"`"
	if [ $# -lt 4 ]; then
		if [ ! -z "${modified_files}" ]; then
			svn_show_which_files_to_commit "Cannot commit ALL files" "${modified_files}"
			return 1
		fi
		return 0
	fi

	# Check whether commiting files matches with the ignored files.
	for i in `seq 1 $#`
	do
		arg_value="${!i}"
		if [ "${arg_value}" = "-m" ]; then
                        break
                fi

		if [ "${arg_value}" = "commit" ]; then
			continue;
		fi

		if [ ! -z "`echo "${modified_files}" | grep "${arg_value}"`" ]; then
			svn_show_which_files_to_commit "Cannot commit ${arg_value}" "${modified_files}"
                        return 1
		fi
	done

	return 0
}

# svn commit
if [ "${SVN_CMD}" = "commit" ]; then
	svn_commit "$@"
	if [ $? -ne 0 ]; then exit 1; fi
fi

# svn stat
if [ "${SVN_CMD}" = "stat" ]; then
	svn_stat "$@"
	exit 0
fi

echo -e "Running as:\t${BASE_SVN} $@" >&2
${BASE_SVN} "$@"
