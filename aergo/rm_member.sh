#!/usr/bin/env bash

if [ "$1" = "" ] ; then
	echo "use:rm_member.sh aergo1~aergo3"
	exit 1
fi

source chain_common.sh

rmnode=$1


# get leader
leader=
getleader leader

getLeaderPort curLeaderPort


raftID=""
getRaftID $curLeaderPort $rmnode raftID

# get leader port

echo "leader=$leader, port=$curLeaderPort, raftId=$raftID"

echo "aergocli -p $curLeaderPort cluster remove --nodeid $raftID"

aergocli -p $curLeaderPort cluster remove --nodeid $raftID

echo "remove Done" 

