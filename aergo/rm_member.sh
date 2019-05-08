#!/usr/bin/env bash

if [ "$1" = "" ] ; then
	echo "use:rm_member.sh aergo4|aergo5"
	exit 1
fi

rmnode=$1

leader=""
leaderport=0

declare -A ports svrports svrname

function getleader() {
	leader=$(aergocli -p 10001 blockchain | jq .ConsensusInfo.Status.Leader)
	leader=${leader//\"/}
	if [[ $leader != aergo* ]]; then
		echo "leader not exist"
		exit 1
	fi

	eval "$1=$leader"
}

function getRaftID() {
	if [ $# != 2 ]; then
		echo "getRafTID $name $outRaftID"
		exit 1
	fi

	name=$1
	pattern=".Bps|.[]|select(.Name==\"$name\")|.RaftID"

	echo "aergocli -p $leaderport getconsensusinfo | jq $pattern"
	raftID=`aergocli -p $leaderport getconsensusinfo | jq $pattern`
	ret=$?
	if [ "$raftID" == "" ]; then
		echo "failed to get raftID for $name"
		exit 2
		eval $2=""
	fi

	echo "raftid=$raftID"
	eval "$2=$raftID"
}

for i in {1..5} ; do
	nodename="aergo$i"

	ports[$nodename]=$((10000 + $i))
	svrport=$((11000 + $i))
	svrports[$nodename]=$svrport
	svrname[$nodename]="BP$svrport"

	httpports[$nodename]=$((13000 + $i))
	peerids[$nodename]=`cat $svrport.id`

	echo "name=${svrname[$nodename]}"
done


# get leader
getleader leader
leaderport=${ports[$leader]}

raftID=""
getRaftID $rmnode raftID

# get leader port

echo "leader=$leader, port=$leaderport, raftId=$raftID"

echo "aergocli -p $leaderport cluster remove --nodeid $raftID"

aergocli -p $leaderport cluster remove --nodeid $raftID

echo "remove Done" 

