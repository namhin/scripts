#!/bin/bash
#

## Don't use the variable name PWD.
BASE_DIR=`dirname $0`

CLASS_BUILDER="$BASE_DIR"/../common/make-class.sh
if [ ! -f "$CLASS_BUILDER" ]; then
	echo "$CLASS_BUILDER doesn't exist or is not a file. Aborting ..." >&2
	exit 2
fi

VALIDATION_TMPL="$BASE_DIR"/tmpl/validation-formset.tmpl
if [ ! -f "$VALIDATION_TMPL" ]; then
	echo "$VALIDATION_TMPL doesn't exist or is not a file. Aborting ..." >&2
	exit 2
fi

BUILD_DIR="build"
if [ ! -d "$BUILD_DIR" ]; then
	mkdir "$BUILD_DIR"
fi
JAVA_BUILD_DIR="$BUILD_DIR/java"
if [ ! -d "$JAVA_BUILD_DIR" ]; then
	mkdir "$JAVA_BUILD_DIR"
fi
JSP_BUILD_DIR="$BUILD_DIR/jsp"
if [ ! -d "$JSP_BUILD_DIR" ]; then
	mkdir "$JSP_BUILD_DIR"
fi

## Create the resource and form-validation file.
APP_RES_FILE="$BUILD_DIR/ApplicationResource.properties"
APP_FORM_VALID_FILE="$BUILD_DIR/validation.xml"
forms_code=

###
create_class() {
	local class_name
	local extends
	local serial_ver
	local pkg_import
	if [ $# -lt 2 ]; then
		return 1
	fi
	
	# Create all the class-building-stuffs.
	pkg_import=$1
	shift 1
	
	class_name=`echo "$1" | sed "s/\([^\^]\+\).*/\1/g"`
	extends=`echo "$1" | grep "\^"`
	if [ ! -z "$extends" ]; then
		extends=`echo "$1" | sed "s/[^\^]\+\^\([^|]\+\).*/\1/g"`
	else
		extends="null"
	fi
	serial_ver=`echo "$1" | grep "|"`
	if [ ! -z "$serial_ver" ]; then
		serial_ver=`echo "$1" | sed "s/[^|]\+|\(.\+\)/\1/g"`
	else
		serial_ver="null"
	fi
	shift 1
	
	# Create the class.
	"$CLASS_BUILDER" "$class_name" "$pkg_import" "$extends" "$serial_ver" "$@" > $JAVA_BUILD_DIR/$class_name.java
	if [ $? -ne 0 ]; then exit 1; fi

	echo "$class_name"

	return 0
}

create_code() {
	local class_name
	local build_html
	local build_res
	local build_form
	
	if [ $# -lt 4 ]; then
		echo "Insufficient arguments in: $0" >&2
		exit 1
	fi
	
	# Save the options.
	build_html=$1
	build_res=$2
	build_form=$3
	shift 3
	
	# Create the class.
	class_name=`create_class "$@"`
	shift 2
	
	# Create the html form if needed.
	if [ $# -gt 0 ]; then
		if [ "$build_html" = "y" ]; then
			. "make-html.sh" "$class_name" "$@" > $JSP_BUILD_DIR/$class_name.jsp
		fi
		
		if [ "$build_res" = "y" ]; then
			. "make-res.sh"  "$class_name" "$@" >> $APP_RES_FILE
		fi
		
		if [ "$build_form" = "y" ]; then
			forms_code=$forms_code`. "make-validation-form.sh" "$class_name" "$@"`
		fi
	fi
}

##################################################################################
## Business: creating the code.

# Application resource file.
echo "##############################################################################" > $APP_RES_FILE

# Package name and import statements for model classes.
model_package="package org.pcasp.project.model;"

# Java and JSP files.
create_code n n n \
            "$model_package\n\nimport org.apache.struts.validator.ValidatorForm;" \
            "UIActionForm^ValidatorForm|8524148496933492524L"

create_code y y y \
            "$model_package" "Person^UIActionForm|-6187631058912176999L" \
            String name String sex

create_code y y y \
            "$model_package" "Student^Person|5964866682853252860L" \
            String name long roll

create_code n n n \
            "$model_package" "ProjectProperties" \
             String prop1 String prop2

# All necessary variables for template has been set.
# Build the validation xml.
. "$VALIDATION_TMPL" > $APP_FORM_VALID_FILE
