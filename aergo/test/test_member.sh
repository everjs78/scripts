#!/usr/bin/env bash
echo "================= raft member add/remove test ===================="

BP_NAME=""

#rm BP*.toml
#./aergoconf-gen.sh 10001 tmpl.toml 5
#clean.sh
#./inittest.sh
source chain_common.sh
source check_sync.sh
clean.sh

rm BP11004* BP11005*

echo ""
echo "======== make initial server ========="
cgen_wallet.sh 

sleep 10

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
echo "========= rm aergo4 ========="
rm_member.sh aergo4
rm BP11004*

checkSync 10001 10003 20 

echo ""
echo "========= rm aergo5 ========="
rm_member.sh aergo5
rm BP11005*

checkSync 10001 10003 20 
