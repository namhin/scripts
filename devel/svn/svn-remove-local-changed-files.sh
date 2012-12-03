#!/bin/bash

LOCAL_CHANGED_FILES="`svn stat $@ | grep "^[M\!]"`"

if [ -z "${LOCAL_CHANGED_FILES}" ]; then
	echo "No local modified files."
else
	echo -e "[ D ] Reverting:\n${LOCAL_CHANGED_FILES}"
	echo "${LOCAL_CHANGED_FILES}" | sed "s/^[M\!][[:space:]]*//g" | xargs -I FILE svn revert FILE
fi

