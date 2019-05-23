#!/usr/bin/env bash
echo "============================== leader change test(try="$1") ============================"

BP_NAME=""

#rm BP*.toml
#./aergoconf-gen.sh 10001 tmpl.toml 5
source chain_common.sh
source check_sync.sh

init=1
chainSleep=1000

if [ "$init" != "0" ];then
	echo ""
	echo "======== make initial server ========="
	clean.sh
	make_node.sh 
fi

kill_svr.sh
DEBUG_CHAIN_BP_SLEEP=$chainSleep run_svr.sh
#run_svr.sh
sleep 3

try=$1
if [ "$try" = "" ];then
	try=10
fi


for ((idx=0; idx<=$try; idx++)); do
	echo "try $idx"
	changeLeader

	# checkProgress
	isChainHang  4
	ret=$?
	echo "isHang=$ret"

	if [ "$ret" = "1" ];then
		echo "============== failed: chain hanged =========="
		exit 100
	fi

	checkLeaderValid
done

checkReorg

echo "============== succeed =========="

