#!/bin/bash

escape_regex_chars() {
	local buffer="";

	buffer=${1//\\/\\\\}; # replace backslash
	buffer=${buffer//\./\\\.}; # replace any .
	buffer=${buffer//\*/\\\*}; # replace quantifier *
	buffer=${buffer//\+/\\\+}; # replace quantifier +
	buffer=${buffer//\?/\\\?}; # replace query
	buffer=${buffer//\^/\\\^}; # replace sol
	buffer=${buffer//'$'/'\$'}; # replace eol
	buffer=${buffer//'|'/'\|'}; # replace or
	buffer=${buffer//'['/'\['}; # replace class open
	buffer=${buffer//']'/'\]'}; # replace class close 
	buffer=${buffer//'{'/'\{'}; # replace bound open
	buffer=${buffer//'}'/'\}'}; # replace bound close
	buffer=${buffer//'('/'\('}; # replace group open
	buffer=${buffer//')'/'\)'}; # replace group close
	buffer=${buffer//\"/\\\"}; # replace double quote
	buffer=${buffer//\'/\\\'}; # replace single quote

   echo -n "$buffer";
}

get_file_user_name() {
	stat -c %U "$1"
}

get_file_group_name() {
	stat -c %G "$1"
}

extract_if_zipped() {
	local base_file
	local base_file_name
	local extracted_file_name

	base_file="$1"
	base_file_name="`basename "${base_file}"`"

	for ext in `get_known_zip_extenstions`
	do
		if [ -z "`echo "${base_file_name}" | grep ".*\.${ext}\$"`" ]; then
			continue
		fi

		extracted_file_name="`find_file_name_if_zipped "${base_file}"`"

		case ${ext} in
			zip )
				unzip "${base_file}"
				;;

			gz )
				gunzip -c "${base_file}" > "${extracted_file_name}"
				;;

			tgz | tar\.gz )
				tar xzf "${base_file}"
				;;

			tbz2 | tar\.bz2 )
				tar xjf "${base_file}"
				;;
		esac

		break
	done
}

find_file_name_if_zipped() {
	for ext in `get_known_zip_extenstions`
	do
		if [ -z "`basename "$1" | grep ".*\.${ext}\$"`" ]; then
			continue
		fi

		basename "$1" | sed "s/\(.*\)\.${ext}\$/\1/g"
		break
	done
}

get_known_zip_extenstions() {
	echo "zip tgz tar.gz tbz2 tar.bz2 gz"
}

##
# Update the conf (2nd arg) with another conf (1st arg).
#
update_conf() {
	local update_from
	local update_to
	local keys
	local values
	local index
	local value
	local updated_conf

	update_from="$1"
	update_to="$2"
	updated_conf="updated-conf.conf"

	keys=(`cat "${update_from}"   | sed "s/^\([^=]\+\)\(=.*\)/\1/g"`)
	values=(`cat "${update_from}" | sed "s/^\([^=]\+\)\(=.*\)/\2/g"`)

	cat "${update_to}" > "${updated_conf}"
	index=0
	for key in ${keys[*]}
	do
		value="${values[${index}]}"

		## If the key we are pushing doesn't exist, then append at the last.
		if [ -z "`cat "${updated_conf}" | grep "$key="`" ]; then
			echo "$key${value}" >> "${updated_conf}"
			continue
		fi

		## If the key we are pushing has empty value, then comment that out.
		if [ "${value}" = "=" ]; then
			cat "${updated_conf}" | sed "s/^${key}=.*$/#\0/g" > "${updated_conf}.tmp"
		else
			cat "${updated_conf}" | sed "s/^#*${key}=.*/$key${value}/g" > "${updated_conf}.tmp"
		fi

		cat "${updated_conf}.tmp" > "${updated_conf}"

		index=`expr ${index} + 1`
	done

	cat "${updated_conf}" > "${update_to}"
	rm -rf "${updated_conf}"
	rm -rf "${updated_conf}.tmp"
}

function min () {
	if(( $1 < $2 )); then
		echo $1
	else
		echo $2
	fi
}

function max () {
	if(( $1 > $2 )); then
		echo $1
	else
		echo $2
	fi
}

get_absolute_path() {
	readlink -f "$1"
}

find_ignoring_repo() {
	find "$1" \( -name ".svn" -prune -o -name ".git" -prune \) -o \( -name "$2" -print \)
}

get_image_height() {
	sips -g pixelHeight "$1" | grep "pixelHeight" | sed -E "s/.*:[[:space:]]*(.*)/\1/g"
}

get_image_width() {
	sips -g pixelWidth "$1" | grep "pixelWidth" | sed -E "s/.*:[[:space:]]*(.*)/\1/g"
}

get_image_size() {
	du -sh "$1" | sed -E "s/^([^[:space:]]*).*/\1/g"
}

escape_regex_chars() {
	local buffer="";

	buffer=${1//\\/\\\\}; # replace backslash
	buffer=${buffer//\./\\\.}; # replace any .
	buffer=${buffer//\*/\\\*}; # replace quantifier *
	buffer=${buffer//\+/\\\+}; # replace quantifier +
	buffer=${buffer//\?/\\\?}; # replace query
	buffer=${buffer//\^/\\\^}; # replace sol
	buffer=${buffer//'$'/'\$'}; # replace eol
	buffer=${buffer//'|'/'\|'}; # replace or
	buffer=${buffer//'['/'\['}; # replace class open
	buffer=${buffer//']'/'\]'}; # replace class close 
	buffer=${buffer//'{'/'\{'}; # replace bound open
	buffer=${buffer//'}'/'\}'}; # replace bound close
	buffer=${buffer//'('/'\('}; # replace group open
	buffer=${buffer//')'/'\)'}; # replace group close
	buffer=${buffer//\"/\\\"}; # replace double quote
	buffer=${buffer//\'/\\\'}; # replace single quote
	echo -n "$buffer";
}

show_error() {
	echo -e "\e[1;31m$1\e[0m"
}

to_single_line() {
	echo "$1" | tr "\n" " "
}

line_num_of_str() {
	echo "$1" | wc -l
}

line_num_of_file() {
	cat "$1" | wc -l
}
