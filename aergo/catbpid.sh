#!/bin/sh
if [ $# != 1 ]; then
	echo "usage: $0 pattern_idfile"
	exit
fi
pattern=$1
ls "$pattern.id" | xargs  awk '{ print "\"" $1 "\"," }'
