#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:"
	echo "   $0  [ /path/to/db_info ]  [ /path/to/the/dump/file ]  [ 'hard' (default) or 'loose' ]"
	echo ""
	echo "Info:"
	echo "   db_info: It is a file having value to the keys: DB_NAME, DB_USER, DB_PASS"
	echo "   dump file: a zip or gz or bz2 sql file"
	echo "   hard/loose: 'hard' will drop DB, create DB, grant privileges. 'loose' will just push the sql to mysql."
	exit 1
fi

DB_INFO="$1"
if [ ! -e "${DB_INFO}" ]; then
	echo "${DB_INFO} doesn't exist."
	exit 1
fi

DB_DUMP_FILE="$2"
if [ ! -e "${DB_DUMP_FILE}" ]; then
	echo "${DB_DUMP_FILE} doesn't exist."
	exit 1
fi

DUMP_TYPE="$3"
if [ -z "${DUMP_TYPE}" ]; then
	DUMP_TYPE="hard"
fi

## Include the DB information.
. "${DB_INFO}"

if [ -z "${DB_NAME}" -o -z "${DB_USER}" -o -z "${DB_PASS}" ]; then
	echo "DB name / user / pass not found."
	exit 1
fi

. "`readlink -f "$0" | xargs dirname`/../generic.inc.sh"

extract_dump_file() {
	echo "Extracting: ${DB_DUMP_FILE}"
	extract_if_zipped "${DB_DUMP_FILE}"

	DB_DUMP_FILE_EXTRACTED="`find_file_name_if_zipped "${DB_DUMP_FILE}"`"
	if [ -z "${DB_DUMP_FILE_EXTRACTED}" ]; then
		EXTRACTED=0
		DB_DUMP_FILE_EXTRACTED="${DB_DUMP_FILE}"
	else
		EXTRACTED=1
	fi
}

remove_extracted_dump_file() {
	if [ ${EXTRACTED} -eq 1 ]; then
		echo "Removing ${DB_DUMP_FILE_EXTRACTED} ..."
		rm -rf ${DB_DUMP_FILE_EXTRACTED}
		if [ $? -ne 0 ]; then exit 5; fi
	fi
}

echo ""
extract_dump_file

if [ "${DUMP_TYPE}" = "hard" ]; then
	ROOT_PASS=
	read -s -p "MySQL root pass: " ROOT_PASS
	if [ -z "$ROOT_PASS" ]; then
		echo "No root password given. Aborting."
		remove_extracted_dump_file
		exit 1
	fi

	echo "Dropping database ..."
	mysql -u root -p${ROOT_PASS} -e "DROP database IF EXISTS ${DB_NAME};"
	if [ $? -ne 0 ]; then exit 4; fi

	echo "Creating database ..."
	mysql -u root -p${ROOT_PASS} -e "CREATE database ${DB_NAME};"
	if [ $? -ne 0 ]; then exit 4; fi

	echo "Granting privileges ..."
	mysql -u root -p${ROOT_PASS} -e "GRANT all privileges on ${DB_NAME}.* to '${DB_USER}'@'${DB_HOST}' identified by '${DB_PASS}' with grant option;"
	if [ $? -ne 0 ]; then exit 4; fi
fi

echo "Pushing data ..."
mysql -u ${DB_USER} -p${DB_PASS} "$DB_NAME" < "${DB_DUMP_FILE_EXTRACTED}"
if [ $? -ne 0 ]; then exit 4; fi

remove_extracted_dump_file

