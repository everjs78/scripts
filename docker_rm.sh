#!/bin/sh
if [ $# -ne 1 ];then
    echo "Usage: $0 container_pattern"
fi

container=$1

docker ps -a | egrep $constainer | awk '{ print $1 }' | xargs docker rm

