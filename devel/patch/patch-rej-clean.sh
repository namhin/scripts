#!/bin/bash

if [ $# -gt 0 ]; then FILE_EXT="$1"; else FILE_EXT="rej"; fi
echo "[ D ] deleting *.${FILE_EXT}"
find . -name "*.${FILE_EXT}" -delete

