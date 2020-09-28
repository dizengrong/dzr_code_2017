#!/bin/sh -l

ebin_pa="ebin ebin_lib"
emulator_flags="+K true +sbwt none +swt low +hms 4096 +hmbs 102400 -env ERL_MAX_ETS_TABLES 20000"

check_and_start_epmd()
{
    epmd=`ps -ef | grep epmd | grep -v grep`
    if [ -z "$epmd" ];then
        erl -noinput -noshell -sname for_start_epmd -s init stop
        echo "epmd started"
    fi
}

is_game_server_pid_exists()
{
    epmd=`ps -ef | grep $1 | grep -v grep`
    if [ -z "$epmd" ];then
        return 0
    else
        return 1
    fi
}

do_dialyzer()
{
    dialyzer_src='-r src/*'
    dialyzer --src -I include $dialyzer_src -o dialyzer_result -pa $ebin_pa
}

do_clean_db()
{
    mnesia_dir=`escript ./script/make_mnesia_dir.escript no_quot`
    read -p "是否确认要删除数据库：$mnesia_dir？(y/n):" answer
    if [ $answer == "y" ];then
        rm -f $mnesia_dir/* 
        echo "clean db in directory:$mnesia_dir succ"
    fi
}

check_dir_can_write()
{
    # return 1 if has write rights other return 0
    test_write=`ls -ld $1|awk '{print $1}'|sed 's/d//g'|grep 'w'|wc -l` 
    if [ "$test_write" -ne 0 ];then
        return 1
    else
        return 0
    fi
}

usr=`whoami`
if [ $usr != 'fbird_ansible' -a $usr != 'jenkins' ];then
    echo "必须使用用户:fbird_ansible（线上服用）或jenkins（发布时用）来进行操作，当前登陆用户：$usr"
    exit 
fi

case $1 in  
    start_epmd)
        erl -noinput -noshell -sname for_start_epmd -s init stop  ;;
    gen_makefile)  
        erlc -o ./ebin/ ./src/tools/gen_makefile.erl
        erl -pa $ebin_pa -noinput -s gen_makefile do ;;
    make_debug)  
        erlc -Werror -I include +debug_info -o ./ebin ./src/user_default.erl
        Worker=`grep -c 'model name' /proc/cpuinfo`
        make debug_mode=true -j $Worker ;;
    make_release)  
        erlc -Werror -I include +debug_info -o ./ebin ./src/user_default.erl
        Worker=`grep -c 'model name' /proc/cpuinfo`
        make -j $Worker ;;
    clean)  
        rm -f ebin/*.beam ;;
    gen_protocol)  
        erlc -o ./ebin/ ./src/tools/gen_protocol.erl
        erl -pa $ebin_pa -noinput -noshell -s gen_protocol gen_all $* ;;
    dialyzer) 
        do_dialyzer $* ;;
    start_shell)
        check_and_start_epmd $*
        mnesia_dir=`escript ./script/make_mnesia_dir.escript`
        erl $emulator_flags -pa $ebin_pa -s main start -mnesia dir $mnesia_dir -mnesia dump_log_write_threshold 10000 ;;
    start)  
        mnesia_dir_no_quot=`escript ./script/make_mnesia_dir.escript no_quot`
        check_dir_can_write $mnesia_dir_no_quot
        if [ $? -eq 0 ];then 
            echo "数据库目录：${mnesia_dir_no_quot}没有写权限！！！"
            exit 
        fi
        is_game_server_pid_exists $mnesia_dir_no_quot
        if [ $? -eq 0 ];then 
            check_and_start_epmd $*
            mnesia_dir=`escript ./script/make_mnesia_dir.escript`
            cmd="erl -noinput -noshell -detached $emulator_flags -pa $ebin_pa -s main start -mnesia dir $mnesia_dir -mnesia dump_log_write_threshold 10000"
            echo $cmd
            $cmd
        else
           echo "游戏服处于启动状态，要重启请先关闭！" 
        fi ;;
    stop)  
        check_and_start_epmd $*
        os_pid=`escript ./script/get_os_pid.escript`
        cmd="erl -noinput -noshell -pa $ebin_pa -s main stop" 
        echo $cmd
        $cmd
        exist_os_pid=$(ps aux | awk '{print $2}'| grep -w $os_pid)
        if [ -z "$exist_os_pid" ] || [ "$exist_os_pid" == "0" ];then
            echo "stop succ, before stop pid:$os_pid, after:$exist_os_pid"
        else
            echo "stop os pid failed, do kill it"
            kill -9 $exist_os_pid
        fi
        log_file=`escript ./script/get_current_log_file.escript`
        if [ -f "$log_file" ];then 
            tail $log_file
        fi ;;
    status)  
        erl -noinput -noshell -pa $ebin_pa -s main check_game_node_status ;;
    remshell)  
        cmd=`erl -pa $ebin_pa -noinput -noshell -s main print_remshell_cmd`
        echo $cmd
        $cmd ;;
    exe_fun)  
        erl -pa $ebin_pa -noinput -noshell -run sm_tool exe_fun $* ;;
    backup) 
        mnesia_dir=`escript ./script/make_mnesia_dir.escript`
        erl -pa $ebin_pa -noinput -noshell -s main backup_db -mnesia dir $mnesia_dir ;;
    migration) 
        erl -pa $ebin_pa -noinput -noshell -s main migration_db $2 $3 $4 $5 ;;
    restore) 
        is_game_server_pid_exists $mnesia_dir_no_quot
        if [ $? -eq 0 ];then 
            mnesia_dir=`escript ./script/make_mnesia_dir.escript`
            erl -pa $ebin_pa -noinput -noshell -s main restore_db $2 -mnesia dir $mnesia_dir
        else
           echo "please stop game server first!" 
        fi ;;
    merge) 
        is_game_server_pid_exists $mnesia_dir_no_quot
        if [ $? -eq 0 ];then 
           mnesia_dir=`escript ./script/make_mnesia_dir.escript`
            erl -pa $ebin_pa -noinput -noshell -run main merge_db $* -mnesia dir $mnesia_dir -mnesia dump_log_write_threshold 1000000
        else
           echo "please stop game server first!" 
        fi ;;
    clean_db) 
        is_game_server_pid_exists $mnesia_dir_no_quot
        if [ $? -eq 0 ];then 
            do_clean_db $*
        else
           echo "please stop game server first!" 
        fi ;;
    reload) 
        erl -pa ebin -noinput -noshell -s main reload $* ;;
    compile_tpl)
        erl -pa ebin ebin_lib -noinput -noshell -s work_helper_main compile_tpl ;;
    *)  
        echo "usage: ./server_ctrl.sh gen_makefile | make_debug | make_release \
             | clean | gen_protocol | dialyzer | start | start_shell | stop \
             | status | remshell | exe_fun | backup | migration | restore | merge | clean_db | reload" ;;  
esac 
