#!/usr/bin/env bash
addnode=$1

if [ "$1" = "" ] || [ "$1" != "aergo4" -a "$1" != "aergo5" ] ;then
	echo "use:add.sh aergo4|aergo5"
	exit 1
fi

# clean
echo "kill_svr & clean 11004, 11005"
kill_svr.sh 11004 11005
rm -rf ./data/11004 ./data/11005
rm -rf ./BP11004.toml ./BP11005.toml


declare -A ports svrports svrname httpports peerids

leader=$(aergocli -p 10001 blockchain | jq .ConsensusInfo.Status.Leader)
leader=${leader//\"/}
if [[ $leader != aergo* ]]; then
	echo "leader not exist"
	exit 1
fi

for i in {1..5} ; do
	nodename="aergo$i"

	ports[$nodename]=$((10000 + $i))
	svrport=$((11000 + $i))
	svrports[$nodename]=$svrport
	svrname[$nodename]="BP$svrport"

	httpports[$nodename]=$((13000 + $i))
	peerids[$nodename]=`cat $svrport.id`

	echo "name=${svrname[$nodename]}"
done


leaderport=${ports[$leader]}

echo "leader=$leader, port=$leaderport"

echo "aergocli -p $leaderport cluster add --name \"$addnode\" --url \"http://127.0.0.1:${httpports[$addnode]}\" --peerid \"${peerids[$addnode]}\""

aergocli -p $leaderport cluster add --name "$addnode" --url "http://127.0.0.1:${httpports[$addnode]}" --peerid "${peerids[$addnode]}"

echo "add Done" 

mySvrport=${svrports[$addnode]}
mySvrName=${svrname[$addnode]}
myConfig="$mySvrName.toml"


for i in {1..5}; do
	echo ${svrname["aergo$i"]}
done
echo "new svr=$mySvrport $mySvrName, $myConfig"

sleep 5

echo "cp ./source/$myConfig ."
cp ./source/$myConfig .

echo "init genesis for $mySvrName"
init_genesis.sh $mySvrName
