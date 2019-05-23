#!/usr/bin/env bash

declare -A ports svrports svrname httpports peerids

for i in {1..5} ; do
	nodename="aergo$i"

	ports[$nodename]=$((10000 + $i))
	svrport=$((11000 + $i))
	svrports[$nodename]=$svrport
	svrname[$nodename]="BP$svrport"

	httpports[$nodename]=$((13000 + $i))
	peerids[$nodename]=`cat $svrport.id`
done


function existProcess() {
    local port=$1

    local proc=$(ps  -ef|grep aergosvr | grep $port | awk '{print $2 }')
    if [ "$proc" = "" ]; then
        echo "not exist"
        return "0"
    fi

    return "1"
}

function getHeight() {
    local port=$1

    local serverport=$(($port + 1000))

	echo "port=$1, serverport=$serverport"

    existProcess $serverport
    if [ "$?" = "0" ]; then
        return "-1"
    fi

    local height=$(aergocli -p $port blockchain | jq .Height)

    return $height
}

function getHash() {
    local port=$1
    local height=$2

	if [ $# != 3 ];then
		echo "usage: getHash port height retHash"
		exit
	fi

    local serverport=$(($port + 1000))
	echo "serverport=$serverport"

    existProcess $serverport
    if [ "$?" = "0" ]; then
        return "-1"
    fi

	echo "aergocli -p $port getblock --number $height | jq .Hash"
    local hash=$(aergocli -p $port getblock --number $height | jq .Hash)

    eval "$3=$hash"
}

function getleader() {
	local curleader=""
	for i in 10001 10002 10003 10004 10005 ; do
		curleader=$(aergocli -p $i blockchain | jq .ConsensusInfo.Status.Leader)
		curleader=${curleader//\"/}
		if [[ "$curleader" == aergo* ]]; then
			break
		fi
	done

	if [[ "$curleader" != aergo* ]]; then
		echo "<get leader failed>"
		exit
	fi

	echo "leader=$curleader"

	eval "$1=$curleader"
}

function getRaftID() {
	if [ $# != 3 ]; then
		echo "getRafTID leaderport name outRaftID"
		exit 1
	fi

	local _leaderport=$1
	local name=$2
	local pattern=".Bps|.[]|select(.Name==\"$name\")|.RaftID"
	local _raftID=

	echo "aergocli -p $_leaderport getconsensusinfo | jq $pattern"
	_raftID=`aergocli -p $_leaderport getconsensusinfo | jq $pattern`
	ret=$?
	if [ "$_raftID" == "" ]; then
		echo "failed to get raftID for $name"
		exit 2
		eval $3=""
	fi

	echo "<raftid=$_raftID>"
	eval "$3=$_raftID"
}

function getRaftState() {
	local name=$1
	
	if [ "$#" != 2 ]; then 
		echo "Usage: getRaftState servername outStateVar"
	fi

	local leaderPort=
	getLeaderPort leaderPort

	# getRaftID
	getRaftID $leaderPort $name raftID

	# getRaftStatus
	local pattern=".Info.Status.progress[\"$raftID\"].state"

	local _raftState=$(aergocli -p $leaderPort getconsensusinfo | jq $pattern)

	echo "<raftState=$_raftState>"

	eval "$2=$_raftState"
}


function getLeaderPort() {
	if [ $# != 1 ]; then
		echo "Usage: getLeaderPort leaderport"
		exit
	fi

	local _leader=""
	getleader _leader

	local _leaderport=${ports[$_leader]}

	if [ "$_leaderport" == "" ];then
		echo "failed to get leader port"
		return 0
		exit
	fi

	eval "$1=$_leaderport"
}


function testxxx() {
	local x
		getleader x

	echo "testleader=$x"
}

function isStableLeader() {
	if [ $# -ne 1 ]; then
		echo 'Usage: isStableLeader timeout. return value=$?'
		exit
	fi

	timeout=$1

	local _prevleader=""
	local _tmpLeader=""

	getleader _prevleader
	getleader _tmpLeader

	for ((i=1;i<=$timeout;i++))
	do 
		if [ "$_prevleader" != "$_tmpLeader" ]; then
			return 0
		fi

		sleep 1
	done

	return 1
}

function changeLeader() {
	if [ "$#" != 0 ];then
		echo "Usage: changeLeader"
		exit
	fi

	local leaderName

	getleader leaderName

	echo "cur leader: $leaderName"
	
	local leaderPort="" 
	leaderPort=${svrports[$leaderName]}
	echo "leaderport=$leaderPort"

	kill_svr.sh $leaderPort
	sleep 2
	DEBUG_CHAIN_BP_SLEEP=$chainSleep run_svr.sh $leaderPort
	sleep 2

	leaderName=""
	getleader leaderName
	echo "new leader: $leaderName"
}

function isChainHang() {
	# "isChainHang: return 1 if true"
	if [ "$#" != "1" ];then
		echo "Usage: isChainHang timeout"
	fi

	# 아무노드나 골라서 5초동안 chain이 증가하고 있는지 확인
	local timeout=$1
	local heightStart=""

	echo "isChainHang($timeout)"
	getHeight 10001
	heightStart=$?

	sleep $timeout

	local heightEnd=""
	getHeight 10001
	heightEnd=$?

	echo "start:$heightStart ~ end:$heightEnd"

	if [ "$heightEnd" = "$heightStart" ];then
		echo "chain is hanged"
		exit 100
	fi

	echo "check succed"

	return 0
}

function checkReorg() {
	reorgCount=$(egrep 'reorg' ./*.log | wc -l | awk '{print $1}')

	if [ "$reorgCount" != "0" ];then
		echo "failed: reorg occured"
		exit 100
	fi
}
