%% @doc 服务器检测，启动时做各种检测，主要是对配置的检测
-module (server_checker).
-include ("common.hrl").
-compile([export_all]).


%% 启动前的检测
check_before_start() -> 
	List = case os:type() of
		{win32, _} -> 
			[
				fun check_config/0,
				% fun check_server_id/0,
				fun check_version_str/0
			];
		_ -> 
			[
				fun check_config/0,
				% fun check_server_id/0,
				fun check_version_str/0,
				fun check_deploy_dir/0,
				fun check_mnesia_dir/0
			]
	end,
	check_start_help(List).


check_start_help([Fun | Rest]) ->
	case Fun() of
		{error, Reason} -> {error, Reason};
		_ -> check_start_help(Rest)
	end;
check_start_help([]) -> ok.


check_config() ->
	List = [
		agent_name,
		server_version,
		game_name,
		serverid,
		log_level,
		log_path,
		cookie,
		server_host,
		net_port,
		timezone,
		{language, [zh_cn, zh_tw, en, ko, ja, vi]},
		sdk,
		gameid,
		gamekey,
		bindips,
		addrbc,
		http_listen_port,
		timezone_secs
	],
	check_config_help(List).

check_config_help([{E, CanSetValues} | Acc]) -> 
	case server_config:get_conf(E) of
		{config_not_exists, _} -> {error, util_str:format_string("config key not exists:~s", [E])};
		Val ->
			case lists:member(Val, CanSetValues) of
				false -> 
					{error, util_str:format_string("config key ~p value must be in:~p", [E, CanSetValues])};
				_ -> 
					check_config_help(Acc)
			end
	end;
check_config_help([E | Acc]) -> 
	case server_config:get_conf(E) of
		{config_not_exists, _} -> {error, util_str:format_string("config key not exists:~s", [E])};
		_ -> check_config_help(Acc)
	end;
check_config_help([]) -> ok. 



check_deploy_dir() ->
	case ?DEBUG_MODE of
		true -> ok;
		_ -> 
			ConfPwd = util_server:make_deploy_dir(),
			{ok, Pwd} = file:get_cwd(),
			case filename:nativename(ConfPwd) == filename:nativename(Pwd) of
				true -> ok;
				_ -> {error, util_str:format_string("deploy dir is wrong:~s, should be:~s!!!", [Pwd, ConfPwd])}
			end
	end.

check_mnesia_dir() ->
	Dir2 = util_server:make_mnesia_dir(),
	Dir1 = mnesia:system_info(directory),
	case filename:nativename(Dir1) == filename:nativename(Dir2) of
		true -> 
			ok;
		false -> 
			{error, util_str:format_string("mnesia dir is wrong:~s, should be:~s!!!", [Dir1, Dir2])}
	end.


check_version_str() ->
	%% 版本字符串必须为:xxxx_两位数字大版本.两位数字小版本
	Version = server_config:get_conf(server_version),
	case length(Version) =< 6 of
		true -> 
			{error, util_str:format_string("version string is wrong:~s", [Version])};
		_ -> 
			[S1, S2, S3, S4, S5, S6] = string:sub_string(Version, length(Version) - 6 + 1),
			case S1 == $_ andalso S4 == $. andalso (S2 >= $0 andalso S2 =< $9) andalso
				 (S3 >= $0 andalso S3 =< $9) andalso (S5 >= $0 andalso S5 =< $9) andalso
				 (S6 >= $0 andalso S6 =< $9) of
				true -> ok;
				_ -> {error, util_str:format_string("version string is wrong:~s", [Version])}
			end
	end.


%% 这个不在需要了，现在通过serverid自动确认为游戏服还是跨服
% check_server_id() -> 
% 	ServerId = server_config:get_conf(serverid), 
% 	case util_server:is_cross_node() of
% 		true -> 
% 			case ServerId >= ?CROSS_NODE_SERVER_ID_MIN andalso ServerId =< ?CROSS_NODE_SERVER_ID_MAX of
% 				true -> ok;
% 				false -> 
% 					Msg = "cross node serverid must in range of [~p, ~p]",
% 					{error, util_str:format_string(Msg, [?CROSS_NODE_SERVER_ID_MIN, ?CROSS_NODE_SERVER_ID_MAX])}
% 			end;
% 		false ->
% 			case  ServerId < ?CROSS_NODE_SERVER_ID_MIN of
% 				true -> ok;
% 				false ->
% 					Msg = "server node serverid must in range of [1, ~p)",
% 					{error, util_str:format_string(Msg, [?CROSS_NODE_SERVER_ID_MIN])}
% 			end
% 	end.


