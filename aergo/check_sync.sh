#!/usr/bin/env bash

source chain_common.sh

# timeout 이 될때까지 검사하여 cur node의 bestno가 src와 3이하로 차이나는 상태가 되면 성공

function checkSync() {
	local srcPort=$1
	local curPort=$2
	local timeout=$3

	echo "============ checkSync $srcPort vs $curPort . timeout=$3sec ==========="
	echo "src=$srcPort, curPort=$curPort, time=$timeout"

	for ((i = 1; i<= $3; i++)); do
		srcHeight=""
		curHeight=""
		getHeight $srcPort 
		srcHeight=$?
		
		getHeight $curPort
		curHeight=$?

		echo "srcno=$srcHeight, curno=$curHeight"

		if [ "$srcHeight" = "-1" ] || [ "$curHeight" = "-1" ]; then
			continue
		fi

		targetNo=$((curHeight + 3))
		if [ $targetNo -gt $srcHeight ]; then
			echo "sync succeed"
			isChainHang 2
			echo ""
			echo ""
			hang=$?
			if [ $hang = 1 ];then
				echo "========= hang after sync ============"
				exit 1
			fi
			return
		fi

		sleep 1
	done

	echo "========= sync failed ============"
	exit 
}


# 현재 sync가 정상적으로 진행중인지 검사
# 현재 best가 remote 에 connect되어 있는 지 확인
function checkSyncRunning() {
    local srcPort=$1
    local curPort=$2
    local try=$3

    local srcHash
    local curHash
    local curHeight

    echo "============ checkSyncRunning $srcPort vs $curPort . try=$3 nums ==========="

    for ((i = 1; i<= $try; i++)); do
        curHeight=""

        getHeight $curPort
        curHeight=$?

        echo "curHeight=$curHeight"

        curHash=""
        getHash $curPort $curHeight curHash
        echo "curHash=$curHash"

        srcHash=""
        getHash $srcPort $curHeight srcHash
        echo "srcHash=$srcHash"


        echo "curHeight=$curHeight, srchash=$srcHash, curhash=$curHash"

        if [ "$curHeight" = "-1" ] || [ "$curHash" = "-1" ] || [ "$srcHash" = "-1" ]; then
			echo "========= sync failed ============"
			exit 
        fi

        if [ "$curHash" != "$srcHash"  ]; then
			echo "========= sync failed ============"
			exit 
        fi

        sleep 1
	done

	echo "=========== sync is running well =========="
	return 0
}

