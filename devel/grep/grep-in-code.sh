#!/bin/bash
grep --exclude-dir=.svn --exclude-dir=.git --exclude-dir=bin --exclude-dir=antbuild --exclude-dir=build --exclude-dir=junk --exclude=*.class "$@"
