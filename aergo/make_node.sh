#!/bin/bash

kill_svr.sh
clean.sh
rm init_*.log

if [ $# != 0 ]; then
    echo "Usage: $0"
    exit
fi

rm -rf genesis
rm -f genesis.json

for file in BP*.toml; do
	bpname=${file%%.toml}
	echo "./init_genesis.sh $bpname"
    init_genesis.sh $bpname > /dev/null 2>&1
done

