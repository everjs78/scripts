#!/bin/sh

port=$1
if [ "$port" == "" ]; then
    port=10001
fi

accountNum=10
txPerAcc=10

rm ./*.txt ./$port ./*.tmp


echo "================ generate txs acc=$accountNum txs=$txPerAcc ==============="

server_dir="../server"
genesis_wallet=$(cat $server_dir/genesis_wallet.txt)
echo "my genesis wallet=$genesis_wallet"
if [ "$genesis_wallet" = "" ]; then
	echo "genesis_wallet is empty"
	exit
fi


sign_tx.sh ${port} $accountNum $txPerAcc
seed_tx.sh $port $genesis_wallet 1

sleep 5
