#!/bin/bash

LOCAL_NEW_FILES="`svn stat $@ | grep "^?"`"

if [ -z "${LOCAL_NEW_FILES}" ]; then
	echo "No local new files."
else
	echo -e "[ D ] Removing:\n${LOCAL_NEW_FILES}"
	echo "${LOCAL_NEW_FILES}" | sed "s/^?[[:space:]]*//g" | xargs -I FILE rm -rf FILE
fi

