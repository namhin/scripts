#!/bin/bash

if [ $# -lt 4 ]; then
	echo "Usage: $0  [ Class Name ]  [ Pkg And Import ]  [ ExtendingClassName or null ]  [ Serial Ver or null ]  [ Type ] [ Member1 ]  [ Type ] [ Member2 ] ..." >&2
	echo "       Don't forget to enclose special stuffs (like List<E>) within double quotation." >&2
	exit 1
fi

## Don't use the variable name PWD.
BASE_DIR=`dirname $0`

# Template for class declaration.
CLASS_TMPL="$BASE_DIR"/tmpl/class.tmpl
if [ ! -f "$CLASS_TMPL" ]; then
	echo "$CLASS_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 2
fi

# Template for getter / setter of a data member.
GET_SET_TMPL="$BASE_DIR"/tmpl/class-get-set.tmpl
if [ ! -f "$GET_SET_TMPL" ]; then
	echo "$GET_SET_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 3
fi

# Template for member declaration.
MEM_DEC_TMPL="$BASE_DIR"/tmpl/class-mem.tmpl
if [ ! -f "$MEM_DEC_TMPL" ]; then
	echo "$MEM_DEC_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 4
fi

# Class name.
class_name="$1"
pkg_import="$2"
extends="$3"
if [ "$extends" = "null" ]; then
	extends=
else
	extends=" extends $extends"
fi
serial_ver="$4"
if [ "$serial_ver" = "null" ]; then
	serial_ver=
else
	serial_ver="\t/**\n\t * The serial version.\n\t */\n\tprivate static final long serialVersionUID = $serial_ver;"
fi
shift 4

mem_declare_codes=
mem_get_set_codes=
methods=
mem_type=
normal_mem=
camel_mem=
mem_val=

while [ $# -gt 0 ]
do
	mem_type="$1"
	shift 1
	if [ $# -le 0 ]; then
		methods="$mem_type"
		break
	fi
	
	normal_mem="$1"
	camel_mem=`echo "$normal_mem" | sed "s/\(.\)\(.*\)/\U\1\E\2/g"`
	shift 1
	
	mem_array=`echo "$mem_type" | grep "\[\]"`
	
	# Determine the default value.
	if [ ! -z "$mem_array" ]; then
		mem_val=`echo "$mem_type" | sed "s/\(.*\)\[\]/new \1[0]/g"`
	elif [ "$mem_type" = "int" -o "$mem_type" = "long" ]; then
		mem_val=0
	elif [ "$mem_type" = "float" ]; then
		mem_val=0.0F
	elif [ "$mem_type" = "double" ]; then
		mem_val=0.0
	elif [ "$mem_type" = "char" ]; then
		mem_val='\0'
	elif [ "$mem_type" = "boolean" ]; then
		mem_val=false
	else
		mem_val=null
	fi

	# Execute the templates.
	mem_declare_codes=$mem_declare_codes`. "$MEM_DEC_TMPL"`
	mem_get_set_codes=$mem_get_set_codes`. "$GET_SET_TMPL"`
done

# All necessary variables for template has been set.
# Build the final output.
. "$CLASS_TMPL"
