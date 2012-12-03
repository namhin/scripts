#!/bin/bash
if [ $# -lt 3 ]; then
	echo "Usage: $0 [ Class Name ] [ Type ] [ Member1 ]  [ Type ] [ Member2 ] ..." >&2
	exit 1
fi

## Don't use the variable name PWD.
BASE_DIR=`dirname $0`

# Template for member declaration.
FORM_TEXT_TMPL="$BASE_DIR"/tmpl/jsp-form-text.tmpl
if [ ! -f "$FORM_TEXT_TMPL" ]; then
	echo "$FORM_TEXT_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 2
fi
FORM_CHECK_TMPL="$BASE_DIR"/tmpl/jsp-form-check.tmpl
if [ ! -f "$FORM_CHECK_TMPL" ]; then
	echo "$FORM_CHECK_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 3
fi
FORM_RADIO_TMPL="$BASE_DIR"/tmpl/jsp-form-radio.tmpl
if [ ! -f "$FORM_RADIO_TMPL" ]; then
	echo "$FORM_RADIO_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 4
fi

class_name="$1"
shift 1

mem_type=
normal_mem=
camel_mem=
style_class=
html_code=
while [ $# -gt 0 ]
do
	mem_type="$1"
	shift 1
	if [ $# -gt 0 ]; then
		normal_mem="$1"
		camel_mem=`echo "$normal_mem" | sed "s/\(.\)\(.*\)/\U\1\E\2/g"`
		if [ "$mem_type" = "boolean" -o "$mem_type" = "Boolean" ]; then
			if [ "$normal_mem" = "isSomething" ]; then
				tmpl=$FORM_RADIO_TMPL
			else
				tmpl=$FORM_CHECK_TMPL
			fi
		else
			tmpl=$FORM_TEXT_TMPL
		fi
		
		# Execute the templates.
		html_code=$html_code`. "$tmpl"`
		shift 1
	fi
done
echo -e "$html_code"
