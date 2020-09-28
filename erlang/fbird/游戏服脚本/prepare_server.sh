#!/bin/sh

# 在这个脚本执行之前，需要先使用root用户创建一个/data目录，并且权限为777

game_name=$1
agent_name=$2

DIR_CODES="/data/codes/"
MNESIA_DB="/data/mnesia_db/"
MNESIA_BACKUP="/data/mnesia_backup/"
MNESIA_MERGE_SRC="/data/mnesia_merge_src/${game_name}_${agent_name}"
OTHER_DATAS_DIR="${MNESIA_DB}/other_datas/"

# =============================== 测试并创建目录 ===============================
if [ ! -d "$DIR_CODES" ];then
	mkdir -p $DIR_CODES
fi

if [ ! -d "$MNESIA_DB" ];then
	mkdir -p $MNESIA_DB
fi

if [ ! -d "$MNESIA_BACKUP" ];then
	mkdir -p $MNESIA_BACKUP
fi

if [ ! -d "$MNESIA_MERGE_SRC" ];then
	mkdir -p $MNESIA_MERGE_SRC
fi

if [ ! -d "$OTHER_DATAS_DIR" ];then
	mkdir -p $OTHER_DATAS_DIR
fi

# ============================ 检测目录是否创建成功 ============================
if [ ! -d "$DIR_CODES" ];then
	echo "创建目录：${DIR_CODES}，失败！！！"
	exit 0
fi

if [ ! -d "$MNESIA_DB" ];then
	echo "创建目录：${MNESIA_DB}，失败！！！"
	exit 0
fi

if [ ! -d "$MNESIA_BACKUP" ];then
	echo "创建目录：${MNESIA_BACKUP}，失败！！！"
	exit 0
fi

if [ ! -d "$MNESIA_MERGE_SRC" ];then
	echo "创建目录：${MNESIA_MERGE_SRC}，失败！！！"
	exit 0
fi

if [ ! -d "$OTHER_DATAS_DIR" ];then
	echo "创建目录：${OTHER_DATAS_DIR}，失败！！！"
	exit 0
fi

echo "所需目录都已创建成功"
