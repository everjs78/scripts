#!/bin/sh
port=$1
if [ "$port" == "" ]; then
    port=10001
fi

generate_tx.sh $port 100

commit_tx.sh
