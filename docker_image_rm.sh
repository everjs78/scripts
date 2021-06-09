#!/bin/sh
if [ $# -ne 1 ];then
    echo "Usage: $0 container_pattern"
fi

img=$1

docker image ls | egrep $img | awk '{ print $3 }' | xargs docker image rm


