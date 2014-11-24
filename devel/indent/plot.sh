#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage:  $0  [ numbers to plot ]"
	echo "            [ if you are piping, consider xargs :) ]"
	exit 1
fi

python -c 'from pylab import *; plot(sys.argv[1:]); show()' "$@"

