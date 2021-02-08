#!/bin/sh
BIN_DIR=$(dirname `realpath $0`)
if [ -z $AEM_HOME ];then
    export AEM_HOME=$(dirname "$BIN_DIR")
fi
