#!/bin/sh
# usage: $0 [bpprefix]
# help :  kill.sh BP11

pattern=$1

if [ -z $pattern ]; then
	pattern="BP"
fi

echo "kill $pattern"
ps -ef| grep aergosvr | grep ${pattern} | awk '{ print $2 }' | xargs kill -9
sleep 3
echo "remain processes..."
echo "$(ps -ef| grep aergosvr |grep -v grep)"
echo "done"
