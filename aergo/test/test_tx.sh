#!/usr/bin/env bash
echo "============================== raft tx test ============================"

BP_NAME=""

#rm BP*.toml
#./aergoconf-gen.sh 10001 tmpl.toml 5
#clean.sh
#./inittest.sh
source chain_common.sh
source check_sync.sh
clean.sh

echo ""
echo "======== make initial server ========="
cgen_wallet.sh 

checkSync 10001 10002 30
checkSync 10001 10003 30

pushd ../client
./run_tx.sh
checkSync 10001 10002 30
checkSync 10001 10003 30
popd

