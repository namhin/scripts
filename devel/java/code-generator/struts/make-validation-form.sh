#!/bin/bash
if [ $# -lt 3 ]; then
	echo "Usage: $0 [ Class Name ] [ Type ] [ Member1 ]  [ Type ] [ Member2 ] ..." >&2
	exit 1
fi

## Don't use the variable name PWD.
BASE_DIR=`dirname $0`

VALID_FORM_TMPL="$BASE_DIR"/tmpl/validation-form.tmpl
if [ ! -f "$VALID_FORM_TMPL" ]; then
	echo "$VALID_FORM_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 2
fi

VALID_FIELD_TMPL="$BASE_DIR"/tmpl/validation-field.tmpl
if [ ! -f "$VALID_FIELD_TMPL" ]; then
	echo "$VALID_FIELD_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 3
fi

class_name="$1"
form_name=`echo "${class_name}Form" | sed "s/\(.\)\(.*\)/\L\1\E\2/g"`
shift 1

normal_mem=
camel_mem=
fields_code=
while [ $# -gt 0 ]
do
	# Discard the attribute type.
	shift 1
	if [ $# -gt 0 ]; then
		normal_mem="$1"
		camel_mem=`echo "$normal_mem" | sed "s/\(.\)\(.*\)/\U\1\E\2/g"`
		
		if [ ! -z "$fields_code" ]; then
			fields_code="$fields_code\n\n"
		fi

		# Execute the templates.
		fields_code=$fields_code`. "$VALID_FIELD_TMPL"`
		shift 1
	fi
done

# All necessary variables for template has been set.
# Build the final output.
. "$VALID_FORM_TMPL"
