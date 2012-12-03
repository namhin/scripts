#!/bin/bash
svn diff $@ > /opt/junk/diff.txt
dos2unix /opt/junk/diff.txt
vim /opt/junk/diff.txt

