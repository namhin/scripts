#!/bin/bash
svn diff `svn stat | grep "^M" | sed "s/^M[[:space:]]*\(.*\)/\1/g" | tr "\n" " "` > /opt/junk/diff.txt
dos2unix /opt/junk/diff.txt
vim /opt/junk/diff.txt

