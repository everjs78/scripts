#!/bin/bash

if [ $# != 3 ]; then
    echo "Usage: $0 <starting port> <template> <max-from 0>"
    exit
fi

# pkgen 명령 위치(path)를 적어줄 것
#pkgen=/blockchain/BK134/pkgen

port0=$1
max=$3
tmpl_file=$2

function gen_array()
{
    omit=$(($1 + 1))
    shift
    
    j=0
    for ((i=1; i <= $max; ++i))
    do
        if [ $i != $omit ]; then
            out[j]=${!i}
            j=$(($j + 1))
        fi
    done

    echo ${out[*]} | sed -e 's= =\,=g' -e 's=\/=\\/=g'
}

for((i=0; i < $max; ++i))
do
    profileport=$(($port0 + $i + 100))
    prof[i]=$profileport
   
    restport=$(($port0 + $i + 200))
    rest[i]=$restport 
    rpcport=$(($port0 + $i))
    rpc[i]=$rpcport
    

    p2pport=$(($port0 + $i + 1000))
    p2p[i]=$p2pport

    pk[i]=${p2pport}.key

    ofile[i]=BP${p2pport}.toml

    aergocli keygen $p2pport
    tempid=$(cat ${p2pport}.id)
    id[i]="\"$(cat ${p2pport}.id)\""
    peer[i]="\"/ip4/127.0.0.1/tcp/${p2pport}/p2p/${tempid}\""

done

ids=$(gen_array -1 ${id[*]})

for((i=0; i < $max; ++i))
do
    peers=$(gen_array ${i} ${peer[*]})

    sed -e "s=_home_=${p2p[i]}=g" \
        -e "s/_prof_/${prof[i]}/g" \
        -e "s/_rest_/${rest[i]}/g" \
	-e "s/_rpc_/${rpc[i]}/g" \
        -e "s/_p2p_/${p2p[i]}/g" \
        -e "s/_peer_/${peers}/g" \
        -e "s/_bps_/$max/g" \
	-e "s/_pk_/${pk[i]}/g" \
        -e "s/_ids_/${ids}/g" $tmpl_file >${ofile[i]}
done
