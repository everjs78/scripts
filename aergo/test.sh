#!/bin/bash
echo "============================== raft server boot & down test ============================"

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

checkSync 10001 10002 30
checkSync 10001 10003 30


for ((idx=0; idx<=3; idx++)); do
	echo "try $idx"
	echo "======== shutdown aergo1 ============"
	kill_svr.sh 11001
	sleep 5
	checkSync 10002 10003 30

	echo "======== restart aergo1 ============"
	run_svr.sh 11001
	sleep 3
	checkSync 10001 10003 30


	echo "======== shutdown aergo2 ============"
	kill_svr.sh 11002
	sleep 5
	checkSync 10001 10003 30

	echo "======== restart aergo2 ============"
	run_svr.sh 11002
	checkSync 10001 10002 30
done
