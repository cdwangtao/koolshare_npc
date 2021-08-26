#!/bin/sh
source /koolshare/scripts/base.sh
eval $(dbus export npc_)
# npc
LOG_FILE=/tmp/upload/npc_log.txt
LOCK_FILE=/var/lock/npc.lock
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
# true > $LOG_FILE

# 设置 锁?
set_lock() {
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}
# 解锁?
unset_lock() {
	flock -u 1000
	rm -rf "$LOCK_FILE"
}
# 时间同步
# sync_ntp(){
# 	# START_TIME=$(date +%Y/%m/%d-%X)
# 	echo_date "尝试从ntp服务器：ntp1.aliyun.com 同步时间..."
# 	ntpclient -h ntp1.aliyun.com -i3 -l -s >/tmp/ali_ntp.txt 2>&1
# 	SYNC_TIME=$(cat /tmp/ali_ntp.txt|grep -E "\[ntpclient\]"|grep -Eo "[0-9]+"|head -n1)
# 	if [ -n "${SYNC_TIME}" ];then
# 		SYNC_TIME=$(date +%Y/%m/%d-%X @${SYNC_TIME})
# 		echo_date "完成！时间同步为：${SYNC_TIME}"
# 	else
# 		echo_date "时间同步失败，跳过！"
# 	fi
# }
# 添加nat-start触发
fun_nat_start(){
	if [ "${npc_enable}" == "1" ];then
		if [ ! -L "/koolshare/init.d/N95npc.sh" ];then
			echo_date "添加npc开机自启动..."
			ln -sf /koolshare/scripts/npc_config.sh /koolshare/init.d/N95npc.sh
		fi
	else
		if [ -L "/koolshare/init.d/N95npc.sh" ];then
			echo_date "删除npc开机自启动..."
			rm -rf /koolshare/init.d/N95npc.sh >/dev/null 2>&1
		fi
	fi
}
# 启动
onstart() {
	# 插件开启的时候同步一次时间
	# if [ "${npc_enable}" == "1" -a -n "$(which ntpclient)" ];then
	# 	sync_ntp
	# fi

	# 关闭npc进程
	if [ -n "$(pidof npc)" ];then
		echo_date "关闭当前npc进程..."
		killall npc >/dev/null 2>&1
	fi
	
	# 插件安装的时候移除npc_client_version，插件第一次运行的时候设置一次版本号即可
	if [ -z "${npc_client_version}" ];then
		dbus set npc_client_version=$(/koolshare/bin/npc --version)
		npc_client_version=$(/koolshare/bin/npc --version)
	fi
	echo_date "当前插件npc主程序版本号：${npc_client_version}"

	# 开启npc
	if [ "$npc_enable" == "1" ]; then
		echo_date "启动npc主程序..."
		export GOGC=40
		# start-stop-daemon -S -q -b -m -p /var/run/npc.pid -x /koolshare/bin/npc -- -c ${CONF_FILE}
		start-stop-daemon -S -q -b -m -p /var/run/npc.pid -x /koolshare/bin/npc -- -vkey=${npc_common_vkey} -server=${npc_common_server_ip}:${npc_common_server_port}

		local npcPID
		local i=10
		until [ -n "$npcPID" ]; do
			i=$(($i - 1))
			npcPID=$(pidof npc)
			if [ "$i" -lt 1 ]; then
				echo_date "npc进程启动失败！"
				echo_date "可能是内存不足造成的，建议使用虚拟内存后重试！"
				close_in_five
			fi
			usleep 250000
		done
		echo_date "npc启动成功，pid：${npcPID}"
		fun_nat_start
		# open_port
	else
		stop
	fi
	echo_date "npc插件启动完毕，本窗口将在5s内自动关闭！"
}
# 检查端口
check_port(){
	local prot=$1
	local port=$2
	local open=$(iptables -S -t filter | grep INPUT | grep dport | grep ${prot} | grep ${port})
	if [ -n "${open}" ];then
		echo 0
	else
		echo 1
	fi
}
# 打开端口
# open_port(){
# }
# 关闭端口
# close_port(){
# }
# 5秒后关闭
close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	dbus set ss_basic_enable="0"
	disable_ss >/dev/null
	echo_date "插件已关闭！！"
	unset_lock
	exit
}
# 停止
stop() {
  # wt增强2.备份配置文件 参数1(是否比较时间拷贝文件 1:比较时间 0:不比较)
  on_back_conf 1
	# 关闭npc进程
	if [ -n "$(pidof npc)" ];then
		echo_date "停止npc主进程，pid：$(pidof npc)"
		killall npc >/dev/null 2>&1
	fi
  # # 删除定时任务1
	# if [ -n "$(cru l|grep npc_monitor)" ];then
	# 	echo_date "删除定时任务1..."
	# 	cru d npc_monitor >/dev/null 2>&1
	# fi
  # # 删除定时任务2
	# if [ -n "$(cru l|grep npc_monitor2)" ];then
	# 	echo_date "删除定时任务2..."
	# 	cru d npc_monitor2 >/dev/null 2>&1
	# fi
  # 删除开机自启动
	if [ -L "/koolshare/init.d/N95npc.sh" ];then
    echo_date "关闭npc开机自启..."
    rm -rf /koolshare/init.d/N95npc.sh >/dev/null 2>&1
  fi
  # 关闭端口
  # close_port
}

# 功能
case $1 in
# 1.启动插件
start)
	set_lock
	if [ "${npc_enable}" == "1" ]; then
		logger "[软件中心]: 启动npc！"
		onstart
	fi
	unset_lock
	;;
# 2.重启插件
restart)
	set_lock
	if [ "${npc_enable}" == "1" ]; then
		stop
		onstart
	fi
	unset_lock
	;;
# 3.停止插件
stop)
	set_lock
	stop
	unset_lock
	;;
# 启动 nat?
start_nat)
	set_lock
	if [ "${npc_enable}" == "1" ]; then
		onstart
	fi
	unset_lock
	;;
 backconf)
  set_lock
	if [ "${npc_enable}" == "1" ]; then
		# wt增强2.备份配置文件 参数1(是否比较时间拷贝文件 1:比较时间 0:不比较)
    on_back_conf 1
	fi
	unset_lock
	;;
esac

# 查看日志
case $2 in
web_submit)
	set_lock
  # 清空日志
  true > $LOG_FILE
	http_response "$1"
	if [ "${npc_enable}" == "1" ]; then
		stop | tee -a $LOG_FILE
		onstart | tee -a $LOG_FILE
	else
		stop | tee -a $LOG_FILE
	fi
	echo XU6J03M6 | tee -a $LOG_FILE
	unset_lock
	;;
esac
