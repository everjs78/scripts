#!/bin/sh
# usage: $0 [bpprefix]
# help :  kill.sh BP11

bpprefix=$1

if [ -z $bpprefix ]; then
	bpprefix="BP"
fi

ps -ef| grep aergosvr | grep ${bpprefix} | awk '{ print $2 }' | xargs kill -9
