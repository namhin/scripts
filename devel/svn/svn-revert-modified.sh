#!/bin/bash
svn revert `svn stat | grep "^M" | sed "s/^M[[:space:]]*\(.*\)/\1/g" | tr "\n" " "`

