#!/usr/bin/env escript

main([]) -> 
	code:add_path("./ebin/"),
	%% 如果是第一次发布，server.config是不存在的，需要生成一个
	check_add_make_config_file(),
	server_config:init(),
	Dir = util_server:make_deploy_dir(),
	filelib:ensure_dir(Dir),
	filelib:ensure_dir(Dir ++ "static/css/"),
	filelib:ensure_dir(Dir ++ "script/"),
	filelib:ensure_dir(Dir ++ "ebin/"),
	filelib:ensure_dir(Dir ++ "ebin_lib/"),
	filelib:ensure_dir(Dir ++ "deps/bin/"),
	copy_files(Dir),
  	io:format("~s", [Dir]).


copy_files(ToDir) ->
	os:cmd("cp ./server_ctrl.sh " ++ ToDir),
	os:cmd("cp deps/bin/cerl_map_api.so " ++ filename:join(ToDir, "deps/bin/")),
	ServerConfig = filename:join(ToDir, "server.config"),
	case filelib:is_file(ServerConfig) of
		true -> skip;
		_ -> 
			os:cmd("cp ./server.config.sample " ++ ServerConfig)
	end,
	VersionFile = filename:join(ToDir, "version.txt"),
	case filelib:is_file(VersionFile) of
		true -> skip;
		_ -> 
			os:cmd("cp ./version.txt " ++ VersionFile)
	end,
	copy_directory("./script/", filename:join(ToDir, "script/")),
	copy_directory("./ebin/", filename:join(ToDir, "ebin/")),
	copy_directory("./ebin_lib/", filename:join(ToDir, "ebin_lib/")),
	copy_directory("./static/", filename:join(ToDir, "static/")),
	ok.

copy_directory(FromDir, ToDir) ->
	os:cmd("rm -f " ++ ToDir),
	os:cmd("cp -r " ++ FromDir ++ "* " ++ ToDir).


check_add_make_config_file() ->
	case filelib:is_file("./server.config") of
		false -> 
			os:cmd("cp ./server.config.sample ./server.config");
		_ -> skip
	end,
	ok.

