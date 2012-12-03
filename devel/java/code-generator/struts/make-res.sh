#!/bin/bash
if [ $# -lt 3 ]; then
	echo "Usage: $0 [ Class Name ] [ Type ] [ Member1 ]  [ Type ] [ Member2 ] ..." >&2
	exit 1
fi

## Don't use the variable name PWD.
BASE_DIR=`dirname $0`

RES_TMPL="$BASE_DIR"/tmpl/app-res.tmpl
if [ ! -f "$RES_TMPL" ]; then
	echo "$RES_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 2
fi

class_name="$1"
shift 1

normal_mem=
camel_mem=
res_code=
while [ $# -gt 0 ]
do
	# Discard the attribute type.
	shift 1
	if [ $# -gt 0 ]; then
		normal_mem="$1"
		camel_mem=`echo "$normal_mem" | sed "s/\(.\)\(.*\)/\U\1\E\2/g"`
		
		# Execute the templates.
		res_code=$res_code`. "$RES_TMPL"`
		shift 1
	fi
done
echo -e "##############################################################################
## For a $class_name.
$res_code\n"
