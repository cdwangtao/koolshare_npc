#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh

# 停止服务
sh /koolshare/scripts/npc_config.sh stop >/dev/null 2>&1

rm -f /koolshare/bin/npc
find /koolshare/init.d/ -name "*npc*" | xargs rm -rf
rm -rf /koolshare/res/icon-npc.png
rm -rf /koolshare/scripts/npc_*.sh
rm -rf /koolshare/webs/Module_npc.asp
rm -f /koolshare/scripts/uninstall_npc.sh
# rm -f /koolshare/configs/npc.ini

values=$(dbus list npc | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done