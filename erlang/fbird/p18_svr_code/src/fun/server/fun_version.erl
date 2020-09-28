%% @doc 服务端版本
%% 从中心服务器获取本游戏服所能接受的客户端版本号列表
%% 然后在玩家登陆时验证
-module (fun_version).
-include("common.hrl").
-export ([get_accept_versions/0, fetch_versions/0, get_versions_call_back/2, is_version_matched/1]).


get_accept_versions() ->
	db:get_all_config(accept_versions).

fetch_versions() ->
	fun_dataCount_update:get_versions().


get_versions_call_back_help(CbRet, Versions) ->
	case CbRet of
		true -> 
			?log_error("server accept versions:~p", [Versions]),
			db:set_all_config(accept_versions, Versions);
		_ ->
			?log_error("get versions failed, Versions:~p, set accept_versions to []", [Versions]),
			db:set_all_config(accept_versions, [])
	end,
	ok.


parse_main_version([], Acc) -> Acc;
parse_main_version([Ver | Rest], Acc) ->
	case string:tokens(util:to_list(Ver), ".") of
		[MainVer | _] -> parse_main_version(Rest, [util:to_integer(MainVer) | Acc]);
		_ -> parse_main_version(Rest, Acc)
	end.


get_versions_call_back({_StatusLine, Body}, _)->
	case  rfc4627:decode(Body)  of  
		{ok, {obj, Datas}, _} ->
			?debug("Datas:~p", [Datas]),
			case lists:keyfind("ErrorCode", 1, Datas) of
				{_, 0}-> 
					{_, Versions} = lists:keyfind("version", 1, Datas),
					Versions2 = [binary_to_list(V) || V <- Versions],
					Versions3 = parse_main_version(Versions2, []),
					get_versions_call_back_help(true, Versions3);
				Ret -> 
					get_versions_call_back_help(false, Ret)
			end;
		_R-> 
			get_versions_call_back_help(false, null)
	end.

is_version_matched(_) -> true.
% is_version_matched(all) -> true;
% is_version_matched(ClientVersion) -> 
% 	ClientVersion2 = util:to_list(ClientVersion),
% 	case string:tokens(ClientVersion2, ".") of
% 		[MainVer | _] -> 
% 			MainVer2 = util:to_integer(MainVer),
% 			lists:member(MainVer2, get_accept_versions());
% 		_ -> false
% 	end.


