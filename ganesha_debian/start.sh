#!/bin/bash

set -e

: ${LOG_FILE:="/dev/stdout"}
: ${LOG_LEVEL:="NIV_EVENT"} # NIV_DEBUG
: ${CONF_FILE:="/etc/ganesha/ganesha.my.conf"}
: ${PID_FILE:="/var/run/ganesha.pid"}
#: ${RPC_STATD_PORT:="662"}

function init_rpc {
    echo "* Starting rpcbind"
    if [ ! -x /run/rpcbind ] ; then
        install -m755 -g 32 -o 32 -d /run/rpcbind
    fi
    rpcbind || return 0
    rpc.statd -L || return 0
    rpc.idmapd || return 0
    sleep 1
}

function init_dbus {
    echo "Starting dbus"
    dbus-daemon --system --nopidfile
    sleep 1
}

init_rpc
init_dbus

echo "Starting Ganesha NFS"
echo "SIGUSR1    : Enable/Disable File Content Cache forced flush"
echo "SIGTERM    : Cleanly terminate the Ganesha NFS"
exec ganesha.nfsd -F -L ${LOG_FILE} -N ${LOG_LEVEL} -f ${CONF_FILE} -p ${PID_FILE}
