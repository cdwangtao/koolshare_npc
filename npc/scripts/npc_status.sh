#! /bin/sh

source $KSROOT/scripts/base.sh
npc_version=$(dbus get npc_client_version)
npc_pid=$(pidof npc)
LOGTIME=$(TZ=UTC-8 date -R "+%Y-%m-%d %H:%M:%S")
if [ -n "$npc_pid" ];then
	http_response "【$LOGTIME】npc ${npc_version} 进程运行正常！（PID：$npc_pid）"
else
	http_response "【$LOGTIME】npc ${npc_version} 进程未运行！"
fi
