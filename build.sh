#!/bin/sh

MODULE="npc"
VERSION="v1.0.0"
TITLE="npc"
DESCRIPTION="npc内网穿透客户端"
HOME_URL="Module_npc.asp"
TAGS="内网穿透 DDNS"
AUTHOR="clang"

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
do_build_result
