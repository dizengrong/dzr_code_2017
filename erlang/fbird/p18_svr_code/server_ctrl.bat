@ECHO OFF

IF "%1" == "gen_makefile" goto gen_makefile
IF "%1" == "make_debug" goto make_debug
IF "%1" == "make_release" goto make_release
IF "%1" == "make_clean" goto clean
IF "%1" == "make_single" goto make_single
IF "%1" == "clean" goto clean
IF "%1" == "gen_protocol" goto gen_protocol
IF "%1" == "gen_pt" goto gen_protocol
IF "%1" == "dialyzer" goto dialyzer
IF "%1" == "start" goto start_game
IF "%1" == "stop" goto stop_game
IF "%1" == "remshell" goto remshell
IF "%1" == "exe_fun" goto exe_fun
IF "%1" == "backup" goto backup
IF "%1" == "migration" goto migration
IF "%1" == "restore" goto restore
IF "%1" == "merge" goto merge
IF "%1" == "clean_db" goto clean_db
IF "%1" == "gen_item_log" goto gen_item_log
IF "%1" == "reload" goto reload
IF "%1" == "compile_tpl" goto compile_tpl
goto usage


:gen_makefile  ::生成用于编译的makefile文件
	erlc +nowarn_export_all -o ./ebin/ ./src/tools/gen_makefile.erl
	erl -pa ebin -noinput -s gen_makefile do
	goto end

:make_debug  ::编译生成debug版代码
	erlc -Werror -I include +debug_info -o ./ebin ./src/user_default.erl
	make debug_mode=true -j %number_of_processors%
	goto end

:make_release  ::编译生成release版代码
	erlc -Werror -I include +debug_info -o ./ebin ./src/user_default.erl
	make -j %number_of_processors%
	goto end

::编译单个文件
:make_single
	echo delete beam file: ebin\%~n2.beam
	del /q ebin\%~n2.beam
	make debug_mode=true -f MakeSingleFile erl_file=%2
	goto end

::clean编译生成的*.beam
:clean
	del /q ebin\*.beam
	goto end

:gen_protocol  ::生成协议
	erlc +nowarn_export_all -o ./ebin/ ./src/tools/gen_new_protocol.erl
	erl -pa ebin -noinput -noshell -s gen_new_protocol gen_all %*
	goto end

::代码静态检测
::第一次使用时要先执行：dialyzer --build_plt --apps erts kernel stdlib mnesia inets
::然后可以用命令添加现有的库到plt：dialyzer --add_to_plt --apps inets
:dialyzer
	SET dialyzer_src=-r ./src/
	dialyzer --src -I include %dialyzer_src% -o dialyzer_result -pa ebin -Ddebug
	goto end

::启动游戏
:start_game
	erl -noinput -noshell -sname for_start_epmd -s init stop
	erl -env ERL_MAX_ETS_TABLES 20000 -pa ebin ebin_lib -s main start -mnesia dir '"database"' -mnesia dump_log_write_threshold 10000 
	::ping \n 1 1 127.1 >nul
	::erl -noinput -noshell -pa ebin -s main check_game_node_status
	goto end

::停止游戏
:stop_game  
	erl -noinput -noshell -pa ebin ebin_lib -s main stop
	goto end

:remshell  ::输出erlang remsh命令
	erl -pa ebin -noinput -noshell -s main print_remshell_cmd
	goto end

::执行一个函数
:exe_fun
	erl -pa ebin -noinput -noshell -run sm_tool exe_fun %*
	goto end

::备份数据库
:backup
	erl -noinput -noshell -sname for_start_epmd -s init stop
	erl -pa ebin -noinput -noshell -s main backup_db -mnesia dir '"database"'
	goto end

::迁移数据库
:migration
	erl -pa ebin -noinput -noshell -s main migration_db %2 %3 %4 %5
	goto end

::迁移数恢复
:restore
	erl -pa ebin -noinput -noshell -s main restore_db %2 -mnesia dir '"database"'
	goto end

::合服 参数为serverid，可以为多个，以空格隔开
:merge
	erl -pa ebin -noinput -noshell -run main merge_db %* -mnesia dir '"database"' -mnesia dump_log_write_threshold 1000000
	goto end

:clean_db
	del /q database\*
	echo "clean success"
	goto end

::生成物品日志文件
:gen_item_log
	erl -pa ebin -noinput -noshell -s gen_item_log do
	goto end

::热更新
:reload
	erl -pa ebin -noinput -noshell -s main reload %*
	goto end

:compile_tpl
	erl -pa ebin ebin_lib -noinput -noshell -s work_helper_main compile_tpl
	goto end

:usage
	echo "usage: %0 start | stop | gen_makefile | gen_protocol | make_debug | make_release | clean | remshell | exe_fun | backup | migration | restore | merge | clean_db"
	goto end


:end
	::exit
