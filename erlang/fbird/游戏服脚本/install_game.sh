#!/bin/sh
# install_game.sh zip代码路径 游戏名称 代理名称 内网地址 server_id 游戏端口 gm下发端口 后台web端口

code_zip=$1
game_name=$2
agent_name=$3
server_host=$4
serverid=$5
net_port=$6
gm_port=$7
web_port=$8

install_dir="/data/${agent_name}/${game_name}/${serverid}/"
db_dir="/data/mnesia_db/${game_name}_${agent_name}_${serverid}/"
if [ -d "$install_dir" ];then
	echo "游戏服目录：${install_dir}已存在，将不执行安装操作了！！！"
	exit 0
else
	mkdir -p $install_dir
	mkdir -p $db_dir
fi

if [ ! -d "$install_dir" ];then
	echo "创建游戏服目录：${install_dir}，失败！！！"
	exit 0
else
	echo "创建游戏服目录：${install_dir}，成功"
fi

unzip -q $code_zip -d $install_dir
if [ $? != 0 ];then
	echo "代码解压错误！！！指定的代码zip文件是否已上传？"
	exit 0
fi
echo "代码解压到：${install_dir}，成功"

cd $install_dir
chmod +x ./server_ctrl.sh

cp server.config.sample server.config
sed -i "s/<serverid>/${serverid}/" server.config
sed -i "s/<server_host>/${server_host}/" server.config
sed -i "s/<net_port>/${net_port}/" server.config
sed -i "s/<web_port>/${web_port}/" server.config
sed -i "s/<http_listen_port>/${gm_port}/" server.config
sed -i "/client_pt_dir/d" server.config
sed -i "/temp_erl_pt_dir/d" server.config
sed -i "/open_gm_code/d" server.config
sed -i "/test_cross_node/d" server.config
sed -i "/test_cross_group/d" server.config
cat server.config
echo "============= 游戏服安装成功！============="

