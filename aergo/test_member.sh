#!/usr/bin/env bash
echo "================= raft member add/remove test ===================="

BP_NAME=""

#rm BP*.toml
#./aergoconf-gen.sh 10001 tmpl.toml 5
#clean.sh
#./inittest.sh
source chain_common.sh
source check_sync.sh

rm BP11004* BP11005*


echo "kill_svr & clean 11004~11007"
kill_svr.sh
for i in  11004 11005 11006 11007; do
	rm -rf ./data/$i
	rm -rf ./BP$i.toml
done

init=1

if [ "$init" != "0" ];then
	echo ""
	echo "======== make initial server ========="
	clean.sh
	make_node.sh 
	sleep 3
fi

echo ""
echo "========= add aergo4 ========="
add_member.sh aergo4
checkSync 10001 10004 30 result

echo ""
echo "========= add aergo5 ========="
add_member.sh aergo5
source check_sync.sh
checkSync 10001 10005 30 


echo ""
echo "========= add aergo6 ========="
add_member.sh aergo6
checkSync 10001 10006 30 result


echo ""
echo "========= add aergo7 ========="
add_member.sh aergo7
source check_sync.sh
checkSync 10001 10007 30 

echo ""
echo "========= rm aergo7 ========="
rm_member.sh aergo7
rm BP11007*
checkSync 10001 10006 20 

echo ""
echo "========= rm aergo6 ========="
rm_member.sh aergo6
rm BP11006*
checkSync 10001 10005 20 

echo ""
echo "========= rm aergo5 ========="
rm_member.sh aergo5
rm BP11005*
checkSync 10001 10004 20 

echo ""
echo "========= rm aergo4 ========="
rm_member.sh aergo4
rm BP11004*
checkSync 10001 10003 20 

echo ""
echo "========= check if reorg occured ======="
checkReorg
