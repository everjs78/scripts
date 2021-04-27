#!/bin/sh
# Copyright (C) 2021 Hyperlounge, All rights reserved.
#
#
# @file    	create_tunnel.sh 
# @brief    make ssh tunnel between private service and remote ssh server
# @author   Jaeseok Ahn <jaeseok.an@hyperlounge.ai>
#
set -x

BASE_DIR="$( cd "$( dirname "$0" )" && pwd -P )"

exit_with_usage() {
    cat << EOF

Usage$ $0 [OPTIONS] REMOTE_PORT

OPTIONS:
    -h, --help          show this help message and exit
    -s, --ssh-server    remote ssh server
    -l, --private-addr  private service address (ex: DB)
    -p, --private-port  private service port
    -u, --user-id       user ID for SSH client
    -k, --key-file      public key of SSH client
EOF
    exit 1
}

###########################
######## Arguments ########
###########################
ssh_server="34.64.84.46"
private_addr=
private_port=
key_file=
user_id=

while [ 1 ]; do
    cnt=$#
    case $1 in
        (-h|--help)     	    exit_with_usage;;
        (-s|--ssh-server)       shift; ssh_server=$1; shift;;
        (-l|--private-addr)     shift; private_addr=$1; shift;;
        (-p|--private-port)     shift; private_port=$1; shift;;
        (-u|--user-id)  	    shift; user_id=$1; shift;;
        (-k|--key-file) 	    shift; key_file=$1; shift;;
        (--)            	    shift; break;;
    esac
    [ $# -eq $cnt ] && { break; }
done
[ $# -lt 1 ] && { exit_with_usage; }
[ -z "$ssh_server" ] || [ -z "$private_addr" ] || [ -z "$private_port" ] || [ -z "$user_id" ] && { exit_with_usage; }
remote_port=$1

# return 0 if tunnel already exist
check_tunnel() {
    echo >&2 "check_tunnel"

    $(ps -ef| grep -v grep  | grep -q "ssh.* $remote_port:$private_addr:$private_port")
    exist=$?

    [ $exist -eq 0 ] && { echo >&2 "tunnel already exist"; }

    echo "$exist"
}


make_tunnel() {
    echo >&2 "make_tunnel"
    ssh -f -N -i $key_file  -R $remote_port:$private_addr:$private_port $user_id@$ssh_server
}

[ $(check_tunnel) != "0" ] && { make_tunnel; }
