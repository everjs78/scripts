#!/bin/sh
# usage: clean [all]
if [ $# -gt 1 ]; then
	echo "usage: clean [all]"
	exit
fi

function rmall(){
	echo "rmall"
	rm -rf *.id *.key *.pub BP*.toml
}

killall -9 aergosvr
rm -rf data* genesis*
#rm *.log

# make empty args to string
if [ "$1" = "all" ]; then
	rmall
fi



