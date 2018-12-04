#!/bin/sh
while [ 1 ]; do 
	for file in BP*.toml; do
		port=$(grep 'netserviceport' $file | awk '{ print $3 }')
		aergocli -p $port blockchain
	done
sleep 1
done
