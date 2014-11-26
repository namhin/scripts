#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage:  $0  [ numbers to plot ]"
	echo "            [ if you are piping, consider 'xargs' :) ]"
	exit 1
fi

python -c '\
from pylab import *;\
plot(sys.argv[1:], color="green", linestyle="dashed", marker="o", markerfacecolor="blue", markersize=8, gid="1");\
grid(True);\
xticklines = getp(gca(), "xticklines");\
yticklines = getp(gca(), "yticklines");\
xgridlines = getp(gca(), "xgridlines");\
ygridlines = getp(gca(), "ygridlines");\
xticklabels = getp(gca(), "xticklabels");\
yticklabels = getp(gca(), "yticklabels");\
setp(xticklines, "linewidth", 3);\
setp(yticklines, "linewidth", 3);\
setp(xgridlines, "linestyle", "-");\
setp(ygridlines, "linestyle", "-");\
setp(yticklabels, "color", "k", fontsize="medium");\
setp(xticklabels, "color", "k", fontsize="medium");\
show();' "$@"

