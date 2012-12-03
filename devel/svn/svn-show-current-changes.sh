#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage:  $0  [ /path/to/project/to/compare/with ] [ Diff command (exmaple: 'meld', 'diff') ]"
	exit 1
fi

COMPARING_PROJECT="$1"
DIFF_CMD="$2"

svn stat | grep "^M" | sed "s/^M[[:space:]]*\(.*\)/\1/g" | xargs -I FILE "${DIFF_CMD}" FILE "${COMPARING_PROJECT}/FILE"

