#!/bin/sh
if [ $# != 1 ]; then
	echo "usage: $0 pattern_idfile"
	exit
fi

function getbasedir() {
	basedir=`basename $0`
}

cd $PWD
pattern=$1
ls $pattern*.id | xargs  awk '{ print "\"" $1 "\"," }'
