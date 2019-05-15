#!/usr/bin/env bash

if [ $# != 1 ];then
	echo "Usage: $0 crashno(0=fatal, 1=error)"
fi

CRASH_NO=$1
method=""
if [ "$CRASH_NO" = "0" ]; then
	method="FATAL"
else 
	method="ERROR"
fi

echo "============================== raft syncer crash test (crash=$method)============================"


BP_NAME=""

#rm BP*.toml
#./aergoconf-gen.sh 10001 tmpl.toml 5
#clean.sh
#./inittest.sh
source check_sync.sh
clean.sh

echo ""
echo "======== make initial server ========="
cgen_wallet.sh 

checkSync 10001 10002 10
checkSync 10001 10003 10

kill_svr.sh 11003

sleep 20
DEBUG_SYNCER_CRASH=$CRASH_NO run_svr.sh 11003
sleep 10

# leader에서 aergo3의 raftstate가 Snapshot이 아니어야 한다. 
# get leaderport
getLeaderPort leaderport
echo "leaderport=$leaderport"

# get raftid for aergo3
name="aergo3"
raftState=
getRaftState $name raftState
echo "state of aergo3 = $raftState"

if [ "$raftState" = "ProgressStateSnapshot" ]; then
	echo "=========== fail : state must not be snapshot =========="
	exit
fi

echo "============== success to catch crash of aergo3 =========="


# restart aergo3
kill_svr.sh 11003
run_svr.sh 11003
checkSync 10001 10003 20

