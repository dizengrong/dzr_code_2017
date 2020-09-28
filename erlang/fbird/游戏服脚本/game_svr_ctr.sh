#!/bin/sh

action=$1
game_name=$2
agent_name=$3


start_all_game()
{
    server_ids=$1
    array=(${server_ids//,/ }) 
    for server_id in ${array[@]}; do
        install_dir="/data/${agent_name}/${game_name}/${server_id}/"
        echo "========================== begin start of ${server_id} =========================="
        if [ -d "$install_dir" ];then
            cd $install_dir
            ./server_ctrl.sh start
        else
            echo "该服还没有安装，不做任何操作！"
        fi
        echo -e "=========================== end start of ${server_id} ===========================\n"
    done
}

stop_all_game()
{
    server_ids=$1
    array=(${server_ids//,/ }) 
    for server_id in ${array[@]}; do
        install_dir="/data/${agent_name}/${game_name}/${server_id}/"
        echo "========================== begin stop of ${server_id} =========================="
        if [ -d "$install_dir" ];then
            cd $install_dir
            ./server_ctrl.sh stop
        else
            echo "该服还没有安装，不做任何操作！"
        fi
        echo -e "=========================== end stop of ${server_id} ===========================\n"
    done
}

update_game_help()
{
    server_id=$1
    code_zip=$2
    install_dir=$3
    echo "========================== begin update of ${server_id} =========================="
    if [ -d "$install_dir" ];then
        cd $install_dir
        echo "stop server..."
        ./server_ctrl.sh stop
        echo "backup db before update..."
        ./server_ctrl.sh backup
        echo "updating code..."
        rm -f ebin/*.beam
        unzip -qo $code_zip -d $install_dir
        if [ $? != 0 ];then
            echo "代码解压错误！！！指定的代码zip文件是否已上传？"
        else
            echo "代码解压到：${install_dir}，成功"
            echo "starting server..."
            ./server_ctrl.sh start
        fi
    else
        echo "该服还没有安装，不做任何操作！"
    fi
    echo -e "=========================== end update of ${server_id} ===========================\n"
}

update_game()
{
    server_id=$1
    code_zip=$2
    install_dir="/data/${agent_name}/${game_name}/${server_id}/"
    update_game_help $server_id $code_zip $install_dir
}

update_all_game()
{
    server_ids=$1
    array=(${server_ids//,/ }) 
    code_zip=$2
    for server_id in ${array[@]}; do
        install_dir="/data/${agent_name}/${game_name}/${server_id}/"
        update_game_help $server_id $code_zip $install_dir
    done
}

remove_game()
{
    server_id=$1
    install_dir="/data/${agent_name}/${game_name}/${server_id}/"
    if [ -d "$install_dir" ];then
        cd $install_dir
        mnesia_dir=`escript ./script/make_mnesia_dir.escript no_quot`
        if [ -d "$mnesia_dir" ];then
            rm -f $mnesia_dir/*
        else
            echo "delete mnesia db dir failed, not find the dir!"
        fi
        cd ..
        rm -rf $install_dir
        echo "remove game in dir:$install_dir succ!"
    else
        echo "not find install dir:$install_dir"
    fi
}


hot_reload_help()
{
    install_dir=$1
    reload_zip_file=$2
    modules=(${3//,/ }) 
    modules2=''
    for m in ${modules[@]}; do
        modules2=${modules2}" ${m}"
    done
    cd $install_dir
    echo "解压热更新文件至：`pwd`/ebin/"
    unzip -qo $reload_zip_file -d ebin/
    echo "开始热更新文件列表: $modules2"
    ./server_ctrl.sh reload $modules2
    sleep 1
    log_file=`escript ./script/get_current_log_file.escript`
    if [ -f "$log_file" ];then 
        tail -n 100 $log_file | grep -B1 mod_server_manage
    else
        echo "没有获取到日志文件！"
    fi
}

hot_reload()
{
    server_id=$1
    reload_zip_file=$2
    install_dir="/data/${agent_name}/${game_name}/${server_id}/"
    hot_reload_help $install_dir $reload_zip_file $3
}

hot_reload_all()
{
    server_ids=$1
    reload_zip_file=$2
    array=(${server_ids//,/ }) 
    for server_id in ${array[@]}; do
        install_dir="/data/${agent_name}/${game_name}/${server_id}/"
        echo "========================== begin hot reload of ${server_id} =========================="
        if [ -d "$install_dir" ];then
            hot_reload_help $install_dir $reload_zip_file $3
        else
            echo "该服还没有安装，不做任何操作！"
        fi
        echo -e "=========================== end hot reload of ${server_id} ===========================\n"
    done
}

game_status()
{
    server_id=$1
    install_dir="/data/${agent_name}/${game_name}/${server_id}/"
    if [ -d "$install_dir" ];then
        echo "游戏服已安装"
        cd $install_dir
        ./server_ctrl.sh status
    else
        echo "该服还没有安装！"
    fi
}


case $1 in  
    start_all_game)
        start_all_game $4 ;;
    stop_all_game)
        stop_all_game $4 ;;
    update_game)
        update_game $4 $5 ;;
    update_all_game)
        update_all_game $4 $5 ;;
    remove_game)
        remove_game $4 ;;
    hot_reload)
        hot_reload $4 $5 $6 ;;
    hot_reload_all)
        hot_reload_all $4 $5 $6 ;;
    game_status)
        game_status $4 ;;
esac 


